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
    @Test("minimal-3_0/Parser-Happy-Path für 3.0.x.")
    func minimal() async throws {
        guard let settingsURL = Bundle.module.url(forResource: "minimal-3_0", withExtension: "yaml") else {
            #expect(Bool(false) , "could not load test fixture")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false) , "could not load test fixture as string, or it is not utf8 enconded.")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
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
        guard let settingsURL = Bundle.module.url(forResource: "02-minimal-31", withExtension: "yaml") else {
            #expect(Bool(false) , "could not load test fixture")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false) , "could not load test fixture as string, or it is not utf8 enconded.")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
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
        let getPingResponseContent = try #require(getPing200Response.content.first?.schema)
        #expect(getPingResponseContent.unevaluatedProperties == false)
        #expect(getPingResponseContent.properties.count == 1)
        #expect(getPingResponseContent.required.count == 1)
        #expect(getPingResponseContent.required.first! == "ok")
        
    }
    @Test("03-params-path-query-header, parameter matrix")
    func parametermatrix() async throws {
        guard let settingsURL = Bundle.module.url(forResource: "03-params-path-query-header", withExtension: "yaml") else {
            #expect(Bool(false) , "could not load test fixture")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false) , "could not load test fixture as string, or it is not utf8 enconded.")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
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
}
