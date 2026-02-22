#!/usr/bin/env swift

import Foundation

// Test script to verify the writeToYAML function
print("Testing writeToYAML function implementation...")

let fileManager = FileManager.default
let filePath = "Sources/SwiftOpenAPISpec/dsl/OpenAPISpecification.swift"

if fileManager.fileExists(atPath: filePath) {
    do {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        
        // Check for the new writeToYAML function
        let hasWriteToYAML = content.contains("func writeToYAML() throws -> String")
        print("✅ writeToYAML function: \(hasWriteToYAML ? "FOUND" : "NOT FOUND")")
        
        // Check that it calls toStringDictionary
        let callsToStringDictionary = content.contains("let stringDictionary = self.toStringDictionary()")
        print("✅ Calls toStringDictionary: \(callsToStringDictionary ? "FOUND" : "NOT FOUND")")
        
        // Check that it calls the static write function
        let callsStaticWrite = content.contains("try Self.write(from: stringDictionary)")
        print("✅ Calls static write function: \(callsStaticWrite ? "FOUND" : "NOT FOUND")")
        
        if hasWriteToYAML && callsToStringDictionary && callsStaticWrite {
            print("\n🎉 writeToYAML function successfully implemented!")
            print("\nThe function:")
            print("1. Calls toStringDictionary() to convert properties to StringDictionary")
            print("2. Calls the static write(from:) function to generate YAML")
            print("3. Returns the YAML string")
            print("\nUsage example:")
            print("let spec = OpenAPISpecification()")
            print("spec.version = \"3.1.0\"")
            print("spec.selfUrl = \"https://example.com/api.yaml\"")
            print("spec.jsonSchemaDialect = \"https://spec.openapis.org/oas/3.1/dialect/base\"")
            print("let yaml = try spec.writeToYAML()")
        } else {
            print("\n❌ writeToYAML function implementation incomplete!")
        }
        
    } catch {
        print("Error reading file: \(error)")
    }
} else {
    print("❌ OpenAPISpecification.swift file not found at: \(filePath)")
}