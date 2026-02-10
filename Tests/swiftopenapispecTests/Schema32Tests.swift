//
//  Schema32Tests.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 22.01.26.
//

import Foundation
import Testing
import Yams
@testable import SwiftOpenAPISpec

@Suite("Schema 3.2 Validation")
struct Schema32ValidationTests {
    typealias ManifestEntry = TestHelpers.ManifestEntry

    @Test("Schema rules for 3.2 hit", arguments: [
        "invalid_schema"
    ])
    func schemaRulesHit(resource: String) async throws {
        let subDirectory = "Resources/3_2/invalid"
        
        guard let resourceUrl = Bundle.module.url(forResource: resource, withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        let dict = try TestHelpers.loadFixtureDictionary(resource, subDirectory: subDirectory)
        let apiSpec = try OpenAPISpecification.read(unflattened: dict, url: resource, documentLoader: YamsDocumentLoader())
        
        guard let fixture = TestHelpers.fixtureManifest(fixtureName: resource, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        try await TestHelpers.validateSchemaAndCompare(
            apiSpec: apiSpec,
            fixture: fixture,
            resourceUrl: resourceUrl,
            resourceName: resource,
            version: ValidationContext.OASVersion.v32,
            dialect: ConverterConfig.Dialect.jsonSchema2020_12
        )
    }
}
