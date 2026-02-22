#!/usr/bin/swift

import Foundation
import Yams
@testable import SwiftOpenAPISpec

// Test the new write functionality
print("Testing OpenAPISpecification write functionality...")

// Test 1: toStringDictionary with basic values
print("\n=== Test 1: toStringDictionary with basic values ===")
let spec = OpenAPISpecification()
spec.version = "3.1.0"
spec.selfUrl = "https://example.com/api.yaml"
spec.jsonSchemaDialect = "https://spec.openapis.org/oas/3.1/dialect/base"

let stringDict = spec.toStringDictionary()
print("StringDictionary count: \(stringDict.count)")
print("Version: \(stringDict[OpenAPISpecification.OPENAPI_KEY]?.stringValue ?? "nil")")
print("Self URL: \(stringDict[OpenAPISpecification.SELF_URL_KEY]?.stringValue ?? "nil")")
print("JSON Schema Dialect: \(stringDict[OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY]?.stringValue ?? "nil")")

// Test 2: write function
print("\n=== Test 2: write function ===")
do {
    let yamlString = try OpenAPISpecification.write(from: stringDict)
    print("Generated YAML:")
    print(yamlString)
} catch {
    print("Error writing YAML: \(error)")
}

// Test 3: Round-trip test
print("\n=== Test 3: Round-trip test ===")
do {
    let yamlString = try OpenAPISpecification.write(from: stringDict)
    print("Generated YAML for round-trip:")
    print(yamlString)
    
    guard let unflattened = try Yams.load(yaml: yamlString) as? StringDictionary else {
        print("Could not parse generated YAML")
        exit(1)
    }
    
    let readSpec = try OpenAPISpecification.read(unflattened: unflattened)
    print("Read back specification:")
    print("Version: \(readSpec.version ?? "nil")")
    print("Self URL: \(readSpec.selfUrl ?? "nil")")
    print("JSON Schema Dialect: \(readSpec.jsonSchemaDialect ?? "nil")")
    
    // Verify values match
    if readSpec.version == spec.version && 
       readSpec.selfUrl == spec.selfUrl && 
       readSpec.jsonSchemaDialect == spec.jsonSchemaDialect {
        print("✅ Round-trip test successful!")
    } else {
        print("❌ Round-trip test failed!")
    }
} catch {
    print("Error in round-trip test: \(error)")
}

// Test 4: Empty dictionary
print("\n=== Test 4: Empty dictionary ===")
do {
    let emptyDict: StringDictionary = [:]
    let yamlString = try OpenAPISpecification.write(from: emptyDict)
    print("Empty dictionary YAML:")
    print(yamlString)
} catch {
    print("Error writing empty dictionary: \(error)")
}

print("\n=== All tests completed ===")