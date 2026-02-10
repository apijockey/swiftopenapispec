#!/usr/bin/swift

import Foundation
import Yams
@testable import SwiftOpenAPISpec

// Testskript zur Validierung der neuen Schema-Tests
func testSchemaValidation() async {
    let testFiles = [
        "10-schematests-array-minitems-negative",
        "10-schematests-array-maxitems-negative", 
        "10-schematests-array-minmaxitems-inconsistent",
        "10-schematests-object-minproperties-negative",
        "10-schematests-object-maxproperties-negative",
        "10-schematests-object-minmaxproperties-inconsistent",
        "10-schematests-object-patternproperties-invalid",
        "10-schematests-object-additionalproperties-inconsistent",
        "10-schematests-enum-invalid"
    ]
    
    let subDirectory = "Tests/swiftopenapispecTests/Resources/3_0/invalid"
    let bundle = Bundle.main
    
    for testFile in testFiles {
        print("Testing: \(testFile)...")
        
        guard let resourceUrl = bundle.url(forResource: testFile, withExtension: "yaml", subdirectory: subDirectory) else {
            print("  ❌ File not found: \(testFile)")
            continue
        }
        
        do {
            let dict = try TestHelpers.loadFixtureDictionary(testFile, subDirectory: subDirectory)
            let apiSpec = try OpenAPISpecification.read(unflattened: dict, url: testFile, documentLoader: YamsDocumentLoader())
            
            let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: testFile, operationIds: [])
            let objectLoader = YamsDocumentLoader()
            var resolver = JSONPointerResolver(baseURL: resourceUrl) { url in
                try await objectLoader.load(from: url)
            }
            
            let errors = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resourceUrl.absoluteString, resolver: &resolver)
            
            if errors.isEmpty {
                print("  ❌ No errors found (expected some)")
            } else {
                print("  ✅ Found \(errors.count) error(s):")
                for error in errors {
                    print("    - \(error.rule): \(error.message)")
                }
            }
            
        } catch {
            print("  ❌ Error running test: \(error)")
        }
        
      
    }
}

// Run the tests
Task {
    await testSchemaValidation()
}

// Keep running for a while to let async tasks complete
RunLoop.main.run(until: Date().addingTimeInterval(5))
