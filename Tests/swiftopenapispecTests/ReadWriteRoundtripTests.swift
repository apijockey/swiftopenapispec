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

@Suite("OpenAPI Write Tests - Swift Testing Format")
struct SwiftTestingOpenAPIWriteTests {
    
    
    @Test func stringDictionary() throws {
        
        var spec = OpenAPISpecification()
        spec.version = "3.1.0"
        spec.selfUrl = "https://example.com/api.yaml"
        spec.jsonSchemaDialect = "https://spec.openapis.org/oas/3.1/dialect/base"
        
        let stringDict = spec.toStringDictionary()
        #expect(stringDict.count == 3)
        #expect(stringDict[OpenAPISpecification.OPENAPI_KEY]?.stringValue == "3.1.0")
        #expect(stringDict[OpenAPISpecification.SELF_URL_KEY]?.stringValue == "https://example.com/api.yaml")
        #expect(stringDict[OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY]?.stringValue  == "https://spec.openapis.org/oas/3.1/dialect/base")
    }
    @Test func emptyDictionary() throws {
        do {
            let emptyDict: StringDictionary = [String:JSONValue]()
            let yamlString = try OpenAPISpecification.write(from: emptyDict)
            print(yamlString)
            #expect(yamlString.contains("{}"))
            
        }
    }
    @Test
    func ToStringDictionaryOptionalValues() throws {
        // Create a specification with only some values set
        var spec = OpenAPISpecification()
        spec.version = "3.0.0"
        // selfUrl and jsonSchemaDialect are nil
        
        let stringDict = spec.toStringDictionary()
        
        // Should only contain the version
        #expect(stringDict.count == 1)
        #expect(stringDict[OpenAPISpecification.OPENAPI_KEY]?.stringValue ==  "3.0.0")
        #expect(stringDict[OpenAPISpecification.SELF_URL_KEY] ==  nil)
        #expect(stringDict[OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY] == nil )
    }
    @Test
    func writeBasicYAML() throws {
        // Create a StringDictionary with basic values
        var stringDict: StringDictionary = [:]
        stringDict[OpenAPISpecification.OPENAPI_KEY] = JSONValue(string: "3.1.0")
        stringDict[OpenAPISpecification.SELF_URL_KEY] = JSONValue(string: "https://example.com/api.yaml")
        stringDict[OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY] = JSONValue(string: "https://spec.openapis.org/oas/3.1/dialect/base")
        
        // Write to YAML
        let yamlString = try OpenAPISpecification.write(from: stringDict)
        
        // Verify the YAML contains the expected values
        #expect(yamlString.contains("openapi: 3.1.0"))
        #expect(yamlString.contains("https://example.com/api.yaml"))
        #expect(yamlString.contains("https://spec.openapis.org/oas/3.1/dialect/base"))
    }
    
    @Test
    func writeEmptyDictionary() throws {
        // Test with empty dictionary
        let emptyDict: StringDictionary = [:]
        let yamlString = try OpenAPISpecification.write(from: emptyDict)
        
        // Should produce valid YAML (possibly empty or with just {})
        #expect(yamlString.count > 0)
        
    }
    @Test
    func testConvertJSONValueToNative() throws {
        // Test the helper function with various JSONValue types
        let testCases: [(JSONValue, Any)] = [
            (.string("test"), "test"),
            (.integer(42), 42),
            (.number(3.14), 3.14),
            (.boolean(true), true)
        ]
        
        for (jsonValue, expected) in testCases {
            let result = try OpenAPISpecification.convertJSONValueToNative(jsonValue)
            
            // Compare the results
            if let expectedString = expected as? String, let resultString = result as? String {
                #expect(resultString == expectedString)
            } else if let expectedInt = expected as? Int, let resultInt = result as? Int {
                #expect(resultInt ==  expectedInt)
            } else if let expectedDouble = expected as? Double, let resultDouble = result as? Double {
                #expect(resultDouble ==  expectedDouble)
            } else if let expectedBool = expected as? Bool, let resultBool = result as? Bool {
                #expect(resultBool == expectedBool)
            }
        }
    }
        
        @Test("writeToYAML with basic values")
        func testWriteToYAMLBasicSwiftTesting() throws {
            var spec = OpenAPISpecification()
            spec.version = "3.1.0"
            spec.selfUrl = "https://example.com/api.yaml"
            spec.jsonSchemaDialect = "https://spec.openapis.org/oas/3.1/dialect/base"
            
            let yamlString = try spec.writeToYAML()
            
            #expect(yamlString.contains("openapi: 3.1.0"))
            #expect(yamlString.contains("https://example.com/api.yaml"))
            #expect(yamlString.contains("https://spec.openapis.org/oas/3.1/dialect/base"))
        }
        
        @Test("writeToYAML round-trip")
        func testWriteToYAMLRoundTripSwiftTesting() throws {
            var originalSpec = OpenAPISpecification()
            originalSpec.version = "3.1.0"
            originalSpec.selfUrl = "https://example.com/api.yaml"
            originalSpec.jsonSchemaDialect = "https://spec.openapis.org/oas/3.1/dialect/base"
            
            let yamlString = try originalSpec.writeToYAML()
            
            guard let map = try Yams.load(yaml: yamlString)  as? [String:Any] else  {
                Issue.record("cannot read yaml-file")
                return
            }
            let jsonValue = try JSONValue(from: map)
            guard case let .object(specObject) = jsonValue else {
                Issue.record("root of generated YAML is not an object")
                return
            }
            
            let readSpec = try OpenAPISpecification.read(unflattened: specObject)
            
            #expect(readSpec.version == originalSpec.version)
            #expect(readSpec.selfUrl == originalSpec.selfUrl)
            #expect(readSpec.jsonSchemaDialect == originalSpec.jsonSchemaDialect)
        }
        
        @Test("writeToYAML with optional values")
        func testWriteToYAMLOptionalValuesSwiftTesting() throws {
            var spec = OpenAPISpecification()
            spec.version = "3.0.0"
            // selfUrl and jsonSchemaDialect are nil
            
            let yamlString = try spec.writeToYAML()
            
            #expect(yamlString.contains("openapi: 3.0.0"))
            #expect(!yamlString.contains("$self:"))
            #expect(!yamlString.contains("jsonSchemaDialect:"))
        }
        @Test("write info element")
        func infoElement() throws {
            var spec = OpenAPISpecification()
            spec.version = "3.0.0"
            var info = OpenAPIInfo()
            info.summary = "Summary Test API"
            info.version = "1.0.0"
            info.title = "Title Example API"
            info.description = "Description A very simple API"
            info.termsOfService = "TermsOfService http://example.com/terms"
            spec.info = info
            let title = try #require(info.title)
            let version = try #require(info.version)
            let summary = try #require(info.summary)
            let description = try #require(info.description)
            let termsOfService = try #require(info.termsOfService)
            let yamlString = try spec.writeToYAML()
            #expect(yamlString.contains(title))
            #expect(yamlString.contains(version))
            #expect(yamlString.contains(summary))
            #expect(yamlString.contains(description))
            #expect(yamlString.contains(termsOfService))
            let readSpec = try TestHelpers.loadSpec(yamlString: yamlString)
            #expect(readSpec.info?.title == title)
            #expect(readSpec.info?.version == version)
            #expect(readSpec.info?.summary == summary)
            #expect(readSpec.info?.description == description)
            #expect(readSpec.info?.termsOfService == termsOfService)
            #expect(readSpec.info == spec.info)
            
        }
    @Test("write license element")
    func licenseElement() throws {
        let version = "3.0.0"
        let info = OpenAPIInfo(version: "1.0.0", title: "test license element")
        var spec = OpenAPISpecification(version: version, info: info)
        var license =    OpenAPILicense(name: "Apache 2")
        license.url = "http://example.com/license"
        spec.info = OpenAPIInfo()
        spec.info?.license = license
        let yamlString = try spec.writeToYAML()
        #expect(yamlString.contains("Apache 2"))
        #expect(yamlString.contains("http://example.com/license"))
        let readSpec = try OpenAPISpecification(yamlString: yamlString)
        let readLicense = readSpec.info?.license
        #expect(readLicense == license)
    }
    
    @Test("write contact element")
    func contactElement() throws {
        let version = "3.0.0"
        let info = OpenAPIInfo(version: "1.0.0", title: "test license element")
        var spec = OpenAPISpecification(version: version, info: info)
        var license =    OpenAPILicense(name: "Apache 2")
        license.url = "http://example.com/license"
        spec.info = OpenAPIInfo()
        spec.info?.license = license
        var contact = OpenAPIContact()
        contact.email = "test@example.com"
        contact.name = "Test User"
        contact.url = "http://example.com/contact"
        spec.info?.contact = contact
        let yamlString = try spec.writeToYAML()
        #expect(yamlString.contains("test@example.com"))
        #expect(yamlString.contains("Test User"))
        #expect(yamlString.contains("http://example.com/contact"))
        let readSpec = try OpenAPISpecification(yamlString: yamlString)
        let readLicense = readSpec.info?.license
        #expect(readLicense == license)
    }
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
