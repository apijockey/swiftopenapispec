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
        let pingAPIPath = try #require(apiSpec[path: "/ping"].first)
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping"].first)
        #expect(getPingOperation.responses?.count == 1)
        
        
        
    }

}
