//
//  Test.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 22.02.26.
//

import Testing
import Foundation
import Yams
@testable import SwiftOpenAPISpec

struct Test {

    @Test func testWrite() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        var spec = OpenAPISpecification()
        spec.version = "3.1.0"
        spec.selfUrl = "https://example.com/api.yaml"
        spec.jsonSchemaDialect = "https://spec.openapis.org/oas/3.1/dialect/base"
        do {
            let yamlString = try spec.writeToYAML()
            print("Generated YAML:")
            print("---")
            print(yamlString)
            print("---")
            
            // Test 3: Round-trip - read back the YAML
            print("\n=== Test 3: Round-trip test ===")
            guard let unflattened = try Yams.load(yaml: yamlString) as? StringDictionary else {
                print("ERROR: Could not parse generated YAML")
                exit(1)
            }
            
            let readSpec = try OpenAPISpecification.read(unflattened: unflattened)
            print("Successfully read back specification:")
            print("  Version: \(readSpec.version ?? "nil")")
            print("  Self URL: \(readSpec.selfUrl ?? "nil")")
            print("  JSON Schema Dialect: \(readSpec.jsonSchemaDialect ?? "nil")")
            
            // Verify values match
            let success = readSpec.version == spec.version &&
                         readSpec.selfUrl == spec.selfUrl &&
                         readSpec.jsonSchemaDialect == spec.jsonSchemaDialect
            
            print("Round-trip test: \(success ? "✅ SUCCESS" : "❌ FAILED")")
            
        } catch {
            print("ERROR: \(error)")
            exit(1)
        }


    }

}









// Test 2: Write to YAML


