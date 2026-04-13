//
//  Schema31Tests.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 22.01.26.
//

import Foundation
import Testing
import Yams
@testable import SwiftOpenAPISpec

@Suite("Schema 3.1 Validation")
struct Schema31ValidationTests {
    typealias ManifestEntry = TestHelpers.ManifestEntry

    @Test("Schema rules for 3.1 hit", arguments: [
        "invalid_schema"
    ])
    func schemaRulesHit(resource: String) async throws {
        let subDirectory = "Resources/3_1/invalid"
        
        guard let resourceUrl = Bundle.module.url(forResource: resource, withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        let dict = try TestHelpers.loadFixtureDictionary(resource, subDirectory: subDirectory)
        let apiSpec = try OpenAPISpecification.read(unflattened: dict, url: resource, documentLoader: YamsDocumentLoader())
        
        guard let fixture = TestHelpers.fixtureManifest(fixtureName: resource, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        try await TestHelpers.assertValidations(
            apiSpec: apiSpec,
            fixture: fixture,
            resourceUrl: resourceUrl,
            resourceName: resource,
            version: ValidationContext.OASVersion.v31,
            dialect: ConverterConfig.Dialect.jsonSchema2020_12,
            assertions: [.Schema]
        )
    }
    @Test("Object with valid PatternProperties")
    func testObjectWithValidPatternProperties() async throws {
        let subDirectory = "Resources/3_1/valid"
        let resource = "10-schematests-object-validPatternProperties"
        
        let dict = try TestHelpers.loadFixtureDictionary(resource, subDirectory: subDirectory)
        let apiSpec = try OpenAPISpecification.read(unflattened: dict, url: resource, documentLoader: YamsDocumentLoader())
        let configSchema = try #require(apiSpec.components?.schemas?[key:"Config"])
        guard case let .object(patternProperty) = configSchema.type else {
            Issue.record("The schema does not have an object type")
            return
        }
        #expect(patternProperty.patternProperties?.count == 2)
        let stringPatternProperty = try #require(patternProperty.patternProperties[keyPath: \.?[key: "^[a-z]+$"]])
        let integerPatternProperty = try #require(patternProperty.patternProperties[keyPath: \.?[key: "^[0-9]+$"]])
       
        #expect(integerPatternProperty.type ==  .integer)
        #expect(stringPatternProperty.type == .string)
        
    }
}
