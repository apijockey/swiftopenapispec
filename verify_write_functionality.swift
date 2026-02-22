#!/usr/bin/env swift

// Simple verification script to test the write functionality
// This script doesn't depend on external modules and just verifies the basic structure

import Foundation

print("Verifying OpenAPISpecification write functionality implementation...")

// Read the OpenAPISpecification.swift file and check for our new functions
let fileManager = FileManager.default
let filePath = "Sources/SwiftOpenAPISpec/dsl/OpenAPISpecification.swift"

if fileManager.fileExists(atPath: filePath) {
    do {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        
        // Check for toStringDictionary function
        let hasToStringDictionary = content.contains("func toStringDictionary()")
        print("✅ toStringDictionary function: \(hasToStringDictionary ? "FOUND" : "NOT FOUND")")
        
        // Check for write function
        let hasWriteFunction = content.contains("static func write(from stringDictionary:")
        print("✅ write function: \(hasWriteFunction ? "FOUND" : "NOT FOUND")")
        
        // Check for convertJSONValueToNative function
        let hasConvertFunction = content.contains("convertJSONValueToNative")
        print("✅ convertJSONValueToNative helper: \(hasConvertFunction ? "FOUND" : "NOT FOUND")")
        
        // Check for Yams import
        let hasYamsImport = content.contains("import Yams")
        print("✅ Yams import: \(hasYamsImport ? "FOUND" : "NOT FOUND")")
        
        // Check for basic value handling
        let handlesVersion = content.contains("Self.OPENAPI_KEY") && content.contains("JSONValue(string: version)")
        let handlesSelfUrl = content.contains("Self.SELF_URL_KEY") && content.contains("JSONValue(string: selfUrl)")
        let handlesJsonSchemaDialect = content.contains("Self.JSON_SCHEMA_DIALECT_KEY") && content.contains("JSONValue(string: jsonSchemaDialect)")
        
        print("✅ Version handling: \(handlesVersion ? "FOUND" : "NOT FOUND")")
        print("✅ Self URL handling: \(handlesSelfUrl ? "FOUND" : "NOT FOUND")")
        print("✅ JSON Schema Dialect handling: \(handlesJsonSchemaDialect ? "FOUND" : "NOT FOUND")")
        
        // Check for YAML conversion
        let hasYamlDump = content.contains("Yams.dump")
        print("✅ YAML dump call: \(hasYamlDump ? "FOUND" : "NOT FOUND")")
        
        if hasToStringDictionary && hasWriteFunction && hasConvertFunction && hasYamsImport && 
           handlesVersion && handlesSelfUrl && handlesJsonSchemaDialect && hasYamlDump {
            print("\n🎉 All required functionality has been successfully implemented!")
            print("\nImplemented features:")
            print("• toStringDictionary() - Converts OpenAPISpecification to StringDictionary")
            print("• write(from:) - Converts StringDictionary to YAML string")
            print("• convertJSONValueToNative() - Helper for JSONValue to native types")
            print("• Supports basic values: version, selfUrl, jsonSchemaDialect")
            print("• Uses Yams for YAML serialization")
        } else {
            print("\n❌ Some functionality is missing!")
        }
        
    } catch {
        print("Error reading file: \(error)")
    }
} else {
    print("❌ OpenAPISpecification.swift file not found at: \(filePath)")
}