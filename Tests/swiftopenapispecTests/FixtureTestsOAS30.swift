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
//  Created by Patric Dubois on 30.11.25.
//

import Foundation
import Yams
import Testing
@testable import SwiftOpenAPISpec

struct FixtureTestsOAS30 {
    enum Errors: LocalizedError, CustomStringConvertible {
        case notFound(String)
        case unreadable(String, Error)
        case notUTF8(String)
        
        var description: String {
            switch self {
            case .notFound(let name): return "Fixture not found: \(name)"
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            }
        }
    }
    private func fixtureMap(_ resource: String, ext: String = "yaml", subDirectory : String? = nil) throws -> JSONValue {
        let name = "\(resource).\(ext)"
        
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw Self.Errors.notFound(name)
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string)  as? [String:Any] else  {
                throw Self.Errors.notUTF8(name)
            }
            let jsonValue = try JSONValue(from: map) 
            return jsonValue
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
    @Test("OAS3.0 Field support rules", arguments: [
        "01-minimal-30-unsupportedSpecFields",
        "02-minimal-30-InfoValidations",
        "02-minimal-30-LicenseValidations"
    ])
    func schemaWarningRulesHit(resource: String) async throws {
        let subDirectory = "Resources/3_0/invalid"
        
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
            version: ValidationContext.OASVersion.v30,
            dialect: ConverterConfig.Dialect.oas30
        )
    }
}
   
    
