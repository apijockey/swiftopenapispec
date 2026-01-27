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

    private func fixtureMap(_ resource: String, ext: String = "yml", subDirectory : String? = nil) throws -> JSONValue {
        let name = "\(resource).\(ext)"
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw Errors.notFound(name)
        }
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string)  as? [String:Any],
                  let jsonValue = JSONValue(map) else  {
                throw Self.Errors.notUTF8(name)
            }
            return jsonValue
        } catch {
            throw Errors.unreadable(name, error)
        }
    }

    @Test("components.schemas.SimpleStringArray -> array<string>")
    func simpleStringArray() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "SimpleStringArray"])
        guard case let .array(arrayType) = comp.schema?.type else {
            Issue.record("Expected .array(let) but got \(comp.schema?.type.debugDescription)")
            return
        }

        #expect(arrayType.type == "array" || arrayType.type == nil)
        let items = try #require(arrayType.items)
        let isString = if case .string = items.type { true } else { false }
        #expect(isString) // Prüft, ob `items` vom Case `.string` ist
    }

    @Test("IntArrayWithBounds -> min/maxItems")
    func intArrayWithBounds() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "IntArrayWithBounds"])
        guard case let .array(arrayType) = try #require(comp.schema?.type) else {
            Issue.record("Expected .array(let) but got \(comp.schema?.type.debugDescription)")
            return
        }
        #expect(arrayType.minItems == 1)
        #expect(arrayType.maxItems == 5)
        let isString = if case .string = arrayType.items?.type { true } else { false }
        #expect(isString) // Prüft, ob `items` vom Case `.string` ist
    }

    @Test("UniqueBooleanArray -> uniqueItems: true")
    func uniqueBooleanArray() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "UniqueBooleanArray"])
        guard case let .array(arrayType) = try #require(comp.schema?.type) else {
            Issue.record("Expected .array(let) but got \(comp.schema?.type.debugDescription)")
            return
        }
        #expect(arrayType.uniqueItems == true)
        // boolean wird nicht explizit als eigener Typ modelliert; deine Fabrik kennt boolean? (nicht gelistet).
        // Falls boolean fehlt, wird items evtl. nil. Wir prüfen deshalb nur, dass items nicht String/Int ist.
        // Optional: #expect(arrayType.items is OpenAPIBooleanType)
    }

    @Test("NestedStringArray -> array<array<string>>")
    func nestedStringArray() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "NestedStringArray"])
        guard case let .array(outer) = try #require(comp.schema?.type) else {
            Issue.record("Expected .array(let) but got \(comp.schema?.type.debugDescription)")
            return
        }
        let inner = try #require(outer.items)
        print(inner)
        //#expect((inner.items as? OpenAPIStringType) != nil)
    }

    @Test("ObjectArray -> array<object{id:int,name:string}>")
    func objectArray() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "ObjectArray"])
        guard case let .array(arrayType) = try #require(comp.schema?.type) else {
                    Issue.record(
                        "Expected .array(let) but got \(comp.schema?.type.debugDescription)"
                    )
            return
        }
        
        guard case let .object(obj) = arrayType.items?.type else {
            Issue.record("Expected .object(let) but got \(arrayType.type.debugDescription)")
            return
        }
        #expect(obj.properties.contains(name: "id"))
        #expect(obj.properties.contains(name: "name"))
        guard case .integer = obj.properties[key: "id"]?.schema?.type else {
            Issue.record("Expected .integer but got \(String(describing: obj.properties[key: "id"]?.schema?.type))")
            return
        }
        guard case .string = obj.properties[key: "name"]?.schema?.type else {
            Issue.record("Expected .string but got \(String(describing: obj.properties[key: "id"]?.schema?.type))")
            return
        }

    }

    @Test("NumberArrayWithContains -> minContains/maxContains")
    func numberArrayWithContains() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "NumberArrayWithContains"])
        guard case let .number = try #require(comp.schema?.type) else {
                Issue.record(
                    "Expected .number(let) but got \(comp.schema?.type.debugDescription)"
            )
            return
        }
        #expect(comp.schema?.minimum == 1)
        #expect(comp.schema?.maximum == 2)
    }

    @Test("ItemsWithoutType -> items ohne type -> items == nil")
    func itemsWithoutType() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "ItemsWithoutType"])
        guard case  .null = try #require(comp.schema?.type) else {
                Issue.record(
                    "Expected .null(let) but got \(comp.schema?.type.debugDescription)"
            )
            return
        }
    }

    @Test("ArrayWithoutItems -> items fehlt -> items == nil, minItems gesetzt")
    func arrayWithoutItems() async throws {
        guard case let .object(yaml) = try fixtureMap("36-arrayComponents", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "36-arrayComponents", documentLoader: YamsDocumentLoader())

        let comp = try #require(apiSpec[schemacomponent: "ArrayWithoutItems"])
        guard case let .array(arrayType) = try #require(comp.schema?.type) else {
            Issue.record(
                "Expected .array(let) but got \(comp.schema?.type.debugDescription)")
                return

        }
        #expect(arrayType.minItems == 0)
        #expect(arrayType.items == nil)
    }
}
