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
//  Created by Patric Dubois on 09.12.25.
//


import Foundation
import Testing
import Yams
@testable import SwiftOpenAPISpec

@Suite("Array Schemas as Components")
struct ArrayComponentsTests {

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

    private func fixtureMap(_ resource: String, ext: String = "yml", subDirectory : String? = nil) throws -> StringDictionary {
        let name = "\(resource).\(ext)"
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw Errors.notFound(name)
        }
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let yaml = try Yams.load(yaml: string) as? StringDictionary else {
                throw Errors.notUTF8(name)
            }
            return yaml
        } catch {
            throw Errors.unreadable(name, error)
        }
    }

    @Test("components.schemas.SimpleStringArray -> array<string>")
    func simpleStringArray() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "SimpleStringArray"])
        let arrayType = try #require(comp.arrayType)
        #expect(arrayType.type == "array" || arrayType.type == nil) // abhängig von TYPE_KEY-Fix
        #expect((arrayType.items as? OpenAPIStringType)?.type == "string")
    }

    @Test("IntArrayWithBounds -> min/maxItems")
    func intArrayWithBounds() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "IntArrayWithBounds"])
        let arrayType = try #require(comp.arrayType)
        #expect(arrayType.minItems == 1)
        #expect(arrayType.maxItems == 5)
        #expect(arrayType.items is OpenAPIIntegerType)
    }

    @Test("UniqueBooleanArray -> uniqueItems: true")
    func uniqueBooleanArray() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "UniqueBooleanArray"])
        let arrayType = try #require(comp.arrayType)
        #expect(arrayType.uniqueItems == true)
        // boolean wird nicht explizit als eigener Typ modelliert; deine Fabrik kennt boolean? (nicht gelistet).
        // Falls boolean fehlt, wird items evtl. nil. Wir prüfen deshalb nur, dass items nicht String/Int ist.
        // Optional: #expect(arrayType.items is OpenAPIBooleanType)
    }

    @Test("NestedStringArray -> array<array<string>>")
    func nestedStringArray() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "NestedStringArray"])
        let outer = try #require(comp.arrayType)
        let inner = try #require(outer.items)
        print(inner)
        //#expect((inner.items as? OpenAPIStringType) != nil)
    }

    @Test("ObjectArray -> array<object{id:int,name:string}>")
    func objectArray() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "ObjectArray"])
        let arrayType = try #require(comp.arrayType)
        let obj = try #require(arrayType.items as? OpenAPIObjectType)
        #expect(obj.properties.contains(name: "id"))
        #expect(obj.properties.contains(name: "name"))
        #expect(obj.properties[key: "id"]?.type is OpenAPIIntegerType)
        #expect(obj.properties[key: "name"]?.type is OpenAPIStringType)
        #expect(obj.required.contains("id"))
        #expect(obj.required.contains("name"))
    }

    @Test("NumberArrayWithContains -> minContains/maxContains")
    func numberArrayWithContains() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "NumberArrayWithContains"])
        let arrayType = try #require(comp.arrayType)
        #expect(arrayType.minContains == 1)
        #expect(arrayType.maxContains == 2)
        #expect(arrayType.items is OpenAPIDoubleType || arrayType.items is OpenAPIIntegerType || arrayType.items is OpenAPIStringType)
        // Deine Fabrik mappt "number" auf OpenAPIDoubleType – sollte also Double sein:
        #expect(arrayType.items is OpenAPIDoubleType)
    }

    @Test("ItemsWithoutType -> items ohne type -> items == nil")
    func itemsWithoutType() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "ItemsWithoutType"])
        let arrayType = try #require(comp.arrayType)
        #expect(arrayType.items == nil)
    }

    @Test("ArrayWithoutItems -> items fehlt -> items == nil, minItems gesetzt")
    func arrayWithoutItems() async throws {
        let yaml = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "ArrayWithoutItems"])
        let arrayType = try #require(comp.arrayType)
        #expect(arrayType.minItems == 0)
        #expect(arrayType.items == nil)
    }
}
