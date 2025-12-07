//
//  Test.swift
//  openapispecreader
//
//  Created by Patric Dubois on 30.11.25.
//

import Foundation
import Testing
@testable import SwiftOpenAPISpec

struct FixtureTests {
    enum Errors: LocalizedError, CustomStringConvertible {
        case notFound(String)
        case unreadable(String, Error)
        case notUTF8(String)

        var description: String {
            switch self {
            case .notFound(let name): return "Fixture not found: \(name)"
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            }
        }
    }
    private func fixtureString(_ resource: String, ext: String = "yaml") throws -> String {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else {
            throw Self.Errors.notFound(name)
        }

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8) else {
                throw Self.Errors.notUTF8(name)
            }
            return string
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
    @Test("minimal-3_0/Parser-Happy-Path für 3.0.x.")
    func minimal() async throws {
        
        let yaml = try fixtureString("minimal-3_0")
        
        let apiSpec = try OpenAPISpec.read(text: yaml)
        #expect(apiSpec.version == "3.0.3")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping"].first)
        #expect(getPingOperation.responses?.count == 1)
        
        
        
    }
    @Test("02 3.1-Path, jsonSchema dialect, modernere Keywords „fit through“.")
    func modernKeywords() async throws {
        
        let yaml = try fixtureString("02-minimal-31")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        #expect(apiSpec.version == "3.1.0")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping31"].first)
        #expect(getPingOperation.responses?.count == 1)
        let responses = try #require(getPingOperation.responses)
        let contentType = try #require(getPingOperation.response(httpstatus: "200")?.content[mediaType: "application/json"])
        #expect(contentType.schema?.type is OpenAPIValidatableObjectType)
        let getPing200Response = try #require(getPingOperation.response(httpstatus:  "200"))
        #expect(getPing200Response.content.count == 1)
        let getPingResponseContent = try #require(getPing200Response.content.first?.schema?.type as? OpenAPIValidatableObjectType)
        #expect(getPingResponseContent.unevaluatedProperties == false)
        #expect(getPingResponseContent.properties.count == 1)
        #expect(getPingResponseContent.required.count == 1)
        #expect(getPingResponseContent.required.first! == "ok")
        
    }
    @Test("03-params-path-query-header, parameter matrix")
    func parametermatrix() async throws {
        
        let yaml = try fixtureString("03-params-path-query-header")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let path = try #require(apiSpec[path: "/pets/{id}"])
        let parameters = try #require(path.operations[operationID : "getPet"]?.parameters)
        #expect(parameters.count == 1)
        let parameter = parameters.first!
        #expect(parameter.name == "id")
        #expect(parameter.location == "path")
        #expect(parameter.schema?.type is OpenAPIValidatableStringType)
        //#expect(parameter.schema?.default == "10")
        //#expect(parameter.schema?.minimum == "1")
        //#expect(parameter.schema?.minimum == "100")
        
        #expect(parameter.explode == nil)
        #expect(parameter.deprecated == nil)
        
        let searchPath = try #require(apiSpec[path: "/pets"])
        let searchParameters = try #require(searchPath.operations[operationID : "searchPets"]?.parameters)
        #expect(parameters.count == 1)
        let queryParameter = searchParameters.first!
        #expect(queryParameter.name == "limit")
        #expect(queryParameter.location == "query")
        let parameterType = try #require(queryParameter.schema?.type as? OpenAPIValidatableIntegerType)
        #expect(parameterType.defaultValue == 10)
        #expect(parameterType.minimum == 1)
        #expect(parameterType.maximum == 100)
        
    }
    @Test("04-requestbody-media-types")
    func mediatypes() async throws {
        
        let yaml = try fixtureString("04-requestbody-media-types")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 2)
        
    }
    @Test("04a-requestbody-media-types-enum")
    func enumtypes() async throws {
        
        let yaml = try fixtureString("04a-requestbody-media-types-enum")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 1)
        let stringType = try #require(requestbodyContents[0].schema?.type as? OpenAPIValidatableStringType)
        #expect(stringType.allowedElements == ["Alice","Bob","Carl"])
        
        
    }
    @Test("04b-requestbody-media-types-array")
    func arraytypes() async throws {
        
        let yaml = try fixtureString("04b-requestbody-media-types-array")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 1)
        let objectType = try #require(requestbodyContents[0].schema?.type as? OpenAPIValidatableObjectType)
        #expect(objectType.properties.count == 2)
        #expect(objectType.properties.contains(where:{$0.key == "productName"}))
        #expect(objectType.properties.contains(where:{$0.key == "productPrice"}))
        #expect(objectType.properties.first?.type is OpenAPIValidatableDoubleType)
        #expect(objectType.properties.last?.type is  OpenAPIValidatableDoubleType)
        
        
    }
}
