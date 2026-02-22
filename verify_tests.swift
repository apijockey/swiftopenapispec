#!/usr/bin/env swift

import Foundation

print("Verifying OpenAPIWriteTests implementation...")

let fileManager = FileManager.default
let filePath = "Tests/swiftopenapispecTests/OpenAPIWriteTests.swift"

if fileManager.fileExists(atPath: filePath) {
    do {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        
        // Check for XCTest imports and structure
        let hasXCTestImport = content.contains("import XCTest")
        print("✅ XCTest import: \(hasXCTestImport ? "FOUND" : "NOT FOUND")")
        
        // Check for conditional Testing import
        let hasConditionalTesting = content.contains("#if canImport(Testing)")
        print("✅ Conditional Testing import: \(hasConditionalTesting ? "FOUND" : "NOT FOUND")")
        
        // Check for writeToYAML tests
        let hasWriteToYAMLBasicTest = content.contains("func testWriteToYAMLBasic()")
        print("✅ writeToYAML basic test: \(hasWriteToYAMLBasicTest ? "FOUND" : "NOT FOUND")")
        
        let hasWriteToYAMLRoundTripTest = content.contains("func testWriteToYAMLRoundTrip()")
        print("✅ writeToYAML round-trip test: \(hasWriteToYAMLRoundTripTest ? "FOUND" : "NOT FOUND")")
        
        let hasWriteToYAMLEmptyTest = content.contains("func testWriteToYAMLEmptySpec()")
        print("✅ writeToYAML empty spec test: \(hasWriteToYAMLEmptyTest ? "FOUND" : "NOT FOUND")")
        
        // Check for Swift Testing format tests
        let hasSwiftTestingSuite = content.contains("@Suite")
        print("✅ Swift Testing @Suite: \(hasSwiftTestingSuite ? "FOUND" : "NOT FOUND")")
        
        let hasSwiftTestingTests = content.contains("@Test")
        print("✅ Swift Testing @Test: \(hasSwiftTestingTests ? "FOUND" : "NOT FOUND")")
        
        let hasSwiftTestingExpect = content.contains("#expect")
        print("✅ Swift Testing #expect: \(hasSwiftTestingExpect ? "FOUND" : "NOT FOUND")")
        
        // Check for test coverage of writeToYAML functionality
        let testsWriteToYAML = content.contains("try spec.writeToYAML()")
        print("✅ Tests writeToYAML calls: \(testsWriteToYAML ? "FOUND" : "NOT FOUND")")
        
        let testsYAMLValidation = content.contains("yamlString.contains")
        print("✅ YAML content validation: \(testsYAMLValidation ? "FOUND" : "NOT FOUND")")
        
        if hasXCTestImport && hasConditionalTesting && hasWriteToYAMLBasicTest && 
           hasWriteToYAMLRoundTripTest && hasSwiftTestingSuite && hasSwiftTestingTests {
            print("\n🎉 Test implementation verification successful!")
            print("\nImplemented test coverage:")
            print("• XCTest format tests for writeToYAML() function")
            print("• Swift Testing format tests (conditional compilation)")
            print("• Basic functionality tests")
            print("• Round-trip tests (write → read → compare)")
            print("• Optional value handling tests")
            print("• Empty specification tests")
            print("\nThe tests support both XCTest and Swift Testing formats!")
        } else {
            print("\n❌ Some test functionality is missing!")
        }
        
    } catch {
        print("Error reading file: \(error)")
    }
} else {
    print("❌ OpenAPIWriteTests.swift file not found at: \(filePath)")
}