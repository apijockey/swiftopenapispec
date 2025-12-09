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
        #expect(contentType.schema?.schemaType is OpenAPIValidatableObjectType)
        let getPing200Response = try #require(getPingOperation.response(httpstatus:  "200"))
        #expect(getPing200Response.content.count == 1)
        let getPingResponseContent = try #require(getPing200Response.content.first?.schema?.schemaType as? OpenAPIValidatableObjectType)
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
        #expect(parameter.schema?.schemaType is OpenAPIValidatableStringType)
      
        
        #expect(parameter.explode == nil)
        #expect(parameter.deprecated == nil)
        
        let searchPath = try #require(apiSpec[path: "/pets"])
        let searchParameters = try #require(searchPath.operations[operationID : "searchPets"]?.parameters)
        #expect(parameters.count == 1)
        let queryParameter = searchParameters.first!
        #expect(queryParameter.name == "limit")
        #expect(queryParameter.location == "query")
        let parameterType = try #require(queryParameter.schema?.schemaType as? OpenAPIValidatableIntegerType)
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
        let stringType = try #require(requestbodyContents[0].schema?.schemaType as? OpenAPIValidatableStringType)
        #expect(stringType.allowedElements == ["Alice","Bob","Carl"])
        
        
    }
    
    @Test("04b-requestbody-media-types-object")
    func arraytypes() async throws {
        
        let yaml = try fixtureString("04b-requestbody-media-types-object")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 1)
        let objectType = try #require(requestbodyContents[0].schema?.schemaType as? OpenAPIValidatableObjectType)
        #expect(objectType.properties.count == 2)
        #expect(objectType.properties.contains(where:{$0.key == "productName"}))
        #expect(objectType.properties.contains(where:{$0.key == "productPrice"}))
        #expect(objectType.properties.first?.type is OpenAPIValidatableStringType)
        #expect(objectType.properties.last?.type is  OpenAPIValidatableDoubleType)
        
        
    }
    
    @Test("05-responses-status-default")
    func components() async throws {
        
        let yaml = try fixtureString("05-responses-status-default")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let operations = try #require(apiSpec[path: "/create"]?.operations)
        #expect(operations.count == 1)
        
        let response201 = try #require(apiSpec[path: "/create"]?.operations[operationID : "create"]?.response(httpstatus: "201"))
        #expect(response201.description == "created")
        #expect((response201.content.first?.schema?.schemaType as? OpenAPIValidatableObjectType)?.required.first  == "id")
        #expect((response201.content.first?.schema?.schemaType as? OpenAPIValidatableObjectType)?.required.count  == 1)
        let defaultResponse = try #require(apiSpec[path: "/create"]?.operations[operationID : "create"]?.response(httpstatus: "default"))
        #expect(defaultResponse.description == "error")
        let component = try #require(defaultResponse.content.first?.schema?.schemaType as? OpenAPIValidatableComponentType)
        #expect(component.ref == "#/components/schemas/Error")
    }
    
    @Test("tictactor-nested-array-elements")
    func nestedArrayElements() async throws {
        let yaml = try fixtureString("tictactoe")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let operations = try #require(apiSpec[path: "/board"]?.operations)
        #expect(operations.count == 1)
        #expect(operations.first?.response(httpstatus: "200")?.content.count == 1)
        let objectType = try #require(operations.first?.response(httpstatus: "200")?.content.first?.schema?.schemaType as? OpenAPIValidatableObjectType)
        #expect(objectType.properties.count == 2)
        let winnerProperty = try #require(objectType.properties["winner"])
        let stringPropertyInfo = try #require(winnerProperty.type as? OpenAPIValidatableStringType )
        #expect(stringPropertyInfo.allowedElements == ["X", "O", "."])
        let boardProperty = try #require((objectType.properties["board"]?.type as? OpenAPIValidatableArrayType))
        #expect(boardProperty.maxItems == 3)
        #expect(boardProperty.minItems == 3)
        let boardSubItems = try #require(boardProperty.items as? OpenAPIValidatableArrayType)
        #expect(boardSubItems.items is OpenAPIValidatableStringType)
        
    }
    
    @Test("07-refs-circular")
    func refscircular() async throws {
        let yaml = try fixtureString("07-refs-circular")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let nodeObjectComponent = try #require(apiSpec.components?.schemas.first?.namedComponentType?.schemaType as? OpenAPIValidatableObjectType)
        #expect(nodeObjectComponent.properties.count == 1)
        #expect(nodeObjectComponent.properties.first?.key == "next")
    }
    
    @Test("08-oneof")
    func oneofanyof() async throws {
        let yaml = try fixtureString("08-oneof-anyof-allof")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let oneOf = try #require(apiSpec[path: "/shape"]?.operations[operationID : "createShape"]?.requestBody?.contents[ mediaType: "application/json"]?.schema?.schemaType as? OpenAPIValidatableOneOfType)
        #expect(oneOf.items?.count == 2)
        
    }
    
    @Test("08a-allof")
    func oneofallof() async throws {
        let yaml = try fixtureString("08a-allof")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let allOf = try #require(apiSpec[path: "/shape"]?.operations[operationID : "createShape"]?.requestBody?.contents[ mediaType: "application/json"]?.schema?.schemaType as? OpenAPIValidatableAllOfType)
        #expect(allOf.items?.count == 2)
        
        
    }
    
    @Test("09-enums-defaults-constraints")
    func enumsdefaultsconstraints() async throws {
        let yaml = try fixtureString("09-enums-defaults-constraints")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        let object = try #require(apiSpec[path: "/order"]?.operations[operationID : "createOrder"]?.requestBody?.contents[ mediaType: "application/json"]?.schema?.schemaType as? OpenAPIValidatableObjectType)
        #expect(object.required.contains( "status"))
        #expect(object.required.contains( "count"))
        #expect(object.properties.contains("count"))
        #expect(object.properties.contains("status"))
        #expect(object.properties.contains("note"))
        let noteProperty = try #require(object.properties["note"]?.type as? OpenAPIValidatableStringType)
        #expect(noteProperty.pattern == "^[A-Z]+$")
    }
    @Test("10-servers-variables")
    func serversvariables() async throws {
        let yaml = try fixtureString("10-servers-variables")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        #expect(apiSpec.servers.count == 1)
        #expect(apiSpec.servers.first?.variables.count == 2)
        let regionVariable = try #require(apiSpec.servers.first?.variables[name: "region"])
        #expect(regionVariable.defaultValue == "eu")
        #expect(regionVariable.enumList == ["eu", "us"])
        let baseVariable = try #require(apiSpec.servers.first?.variables[name: "basePath"])
        #expect(baseVariable.defaultValue == "v1")
        
    }
    @Test("11-contenttype-vendor-json")
    func contenttypevendor() async throws {
        let yaml = try fixtureString("11-contenttype-vendor-json")
        let apiSpec = try OpenAPISpec.read(text: yaml)
        #expect(apiSpec[path: "/fail"]?.operations[operationID: "fail"]?.responses?[httpstatus: "400"]?.content[mediaType: "application/problem+json"]?.schema?.schemaType is OpenAPIValidatableObjectType)
    }
}
