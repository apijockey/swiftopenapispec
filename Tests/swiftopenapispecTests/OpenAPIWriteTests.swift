/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
import Yams
@testable import SwiftOpenAPISpec

final class OpenAPIWriteTests: XCTestCase {

    func testToStringDictionaryBasicValues() throws {
        // Create a basic OpenAPISpecification with only the basic values
        var spec = OpenAPISpecification()
        spec.version = "3.1.0"
        spec.selfUrl = "https://example.com/api.yaml"
        spec.jsonSchemaDialect = "https://spec.openapis.org/oas/3.1/dialect/base"

        // Convert to StringDictionary
        let stringDict = spec.toStringDictionary()

        // Verify the dictionary contains the expected keys and values
        XCTAssertEqual(stringDict.count, 3)
        XCTAssertEqual(stringDict[OpenAPISpecification.OPENAPI_KEY]?.stringValue, "3.1.0")
        XCTAssertEqual(stringDict[OpenAPISpecification.SELF_URL_KEY]?.stringValue, "https://example.com/api.yaml")
        XCTAssertEqual(stringDict[OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY]?.stringValue, "https://spec.openapis.org/oas/3.1/dialect/base")
    }

    func testToStringDictionaryOptionalValues() throws {
        // Create a specification with only some values set
        var spec = OpenAPISpecification()
        spec.version = "3.0.0"
        // selfUrl and jsonSchemaDialect are nil

        let stringDict = spec.toStringDictionary()

        // Should only contain the version
        XCTAssertEqual(stringDict.count, 1)
        XCTAssertEqual(stringDict[OpenAPISpecification.OPENAPI_KEY]?.stringValue, "3.0.0")
        XCTAssertNil(stringDict[OpenAPISpecification.SELF_URL_KEY])
        XCTAssertNil(stringDict[OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY])
    }

    func testWriteBasicYAML() throws {
        // Create a StringDictionary with basic values
        var stringDict: StringDictionary = [:]
        stringDict[OpenAPISpecification.OPENAPI_KEY] = JSONValue(string: "3.1.0")
        stringDict[OpenAPISpecification.SELF_URL_KEY] = JSONValue(string: "https://example.com/api.yaml")
        stringDict[OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY] = JSONValue(string: "https://spec.openapis.org/oas/3.1/dialect/base")

        // Write to YAML
        let yamlString = try OpenAPISpecification.write(from: stringDict)

        // Verify the YAML contains the expected values
        XCTAssertTrue(yamlString.contains("openapi: 3.1.0"))
        XCTAssertTrue(yamlString.contains("https://example.com/api.yaml"))
        XCTAssertTrue(yamlString.contains("https://spec.openapis.org/oas/3.1/dialect/base"))
    }

    func testWriteAndReadRoundTrip() throws {
        // Create a specification
        var originalSpec = OpenAPISpecification()
        originalSpec.version = "3.1.0"
        originalSpec.selfUrl = "https://example.com/api.yaml"
        originalSpec.jsonSchemaDialect = "https://spec.openapis.org/oas/3.1/dialect/base"

        // Convert to StringDictionary and then to YAML
        let stringDict = originalSpec.toStringDictionary()
        let yamlString = try OpenAPISpecification.write(from: stringDict)

        // Read the YAML back
        guard let unflattened = try Yams.load(yaml: yamlString) as? StringDictionary else {
            XCTFail("Could not parse generated YAML")
            return
        }

        let readSpec = try OpenAPISpecification.read(unflattened: unflattened)

        // Verify the values match
        XCTAssertEqual(readSpec.version, originalSpec.version)
        XCTAssertEqual(readSpec.selfUrl, originalSpec.selfUrl)
        XCTAssertEqual(readSpec.jsonSchemaDialect, originalSpec.jsonSchemaDialect)
    }

    func testWriteEmptyDictionary() throws {
        // Test with empty dictionary
        let emptyDict: StringDictionary = [:]
        let yamlString = try OpenAPISpecification.write(from: emptyDict)

        // Should produce valid YAML (possibly empty or with just {})
        XCTAssertNotNil(yamlString)
        print("Empty dict YAML: \(yamlString)")
    }

    func testConvertJSONValueToNative() throws {
        // Test the helper function with various JSONValue types
        let testCases: [(JSONValue, Any)] = [
            (.string("test"), "test"),
            (.integer(42), 42),
            (.number(3.14), 3.14),
            (.boolean(true), true),
            (.null, NSNull())
        ]

        for (jsonValue, expected) in testCases {
            let result = try OpenAPISpecification.convertJSONValueToNative(jsonValue)
            
            // Compare the results
            if let expectedString = expected as? String, let resultString = result as? String {
                XCTAssertEqual(resultString, expectedString)
            } else if let expectedInt = expected as? Int, let resultInt = result as? Int {
                XCTAssertEqual(resultInt, expectedInt)
            } else if let expectedDouble = expected as? Double, let resultDouble = result as? Double {
                XCTAssertEqual(resultDouble, expectedDouble)
            } else if let expectedBool = expected as? Bool, let resultBool = result as? Bool {
                XCTAssertEqual(resultBool, expectedBool)
            } else if expected is NSNull {
                XCTAssertTrue(result is NSNull)
            } else {
                XCTFail("Unexpected type comparison")
            }
        }
    }

    func testWriteComplexStructure() throws {
        // Test with a more complex structure including nested objects
        var stringDict: StringDictionary = [:]
        stringDict[OpenAPISpecification.OPENAPI_KEY] = JSONValue(string: "3.1.0")
        
        // Add a nested object (simulating future info structure)
        var infoDict: StringDictionary = [:]
        infoDict["title"] = JSONValue(string: "Test API")
        infoDict["version"] = JSONValue(string: "1.0.0")
        stringDict["info"] = JSONValue.object(infoDict)

        // Write to YAML
        let yamlString = try OpenAPISpecification.write(from: stringDict)

        // Verify the YAML contains the expected values
        XCTAssertTrue(yamlString.contains("openapi: 3.1.0"))
        XCTAssertTrue(yamlString.contains("title: Test API"))
        XCTAssertTrue(yamlString.contains("version: 1.0.0"))
        
        print("Complex YAML output:\n\(yamlString)")
    }
}
