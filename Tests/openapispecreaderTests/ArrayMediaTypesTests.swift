/*
 * Copyright 2025 CgSe ...
 */

import Foundation
import Testing
import Yams
import SwiftOpenAPISpec

@Suite("Array MediaTypes (paths -> request/response)")
struct ArrayMediaTypesTests {

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

    private func fixtureMap(_ resource: String, ext: String = "yaml") throws -> StringDictionary {
        let name = "\(resource).\(ext)"
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else {
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

    @Test("GET /tags -> 200 -> application/json: array<string> with minItems")
    func getTagsResponseArrayOfString() async throws {
        let yaml = try fixtureMap("37-array-mediatypes")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "37-array-mediatypes", documentLoader: YamsDocumentLoader())

        let path = try #require(apiSpec[path: "/tags"])
        let getOp = try #require(path[operationId: "getTags"].first)

        let response200 = try #require(getOp.response(httpstatus: "200"))
        let media = try #require(response200.content[key: "application/json"])
        let schemaType = try #require(media.schema?.schemaType as? OpenAPIArrayType)

        // Array-Constraints
        #expect(schemaType.minItems == 1)
        // items: string
        let itemsType = try #require(schemaType.items as? OpenAPIStringType)
        #expect(itemsType.type == "string")
    }

    @Test("POST /tags -> requestBody -> application/json: array<object> uniqueItems")
    func postTagsRequestArrayOfObject() async throws {
        let yaml = try fixtureMap("37-array-mediatypes")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "37-array-mediatypes", documentLoader: YamsDocumentLoader())

        let path = try #require(apiSpec[path: "/tags"])
        let postOp = try #require(path[operationId: "createTags"].first)

        let reqBody = try #require(postOp.requestBody)
        let media = try #require(reqBody.contents[key: "application/json"])
        let schemaType = try #require(media.schema?.schemaType as? OpenAPIArrayType)

        // Array-Flag
        #expect(schemaType.uniqueItems == true)

        // items: object mit properties id:int, name:string
        let objectItems = try #require(schemaType.items as? OpenAPIObjectType)
        #expect(objectItems.properties.count == 2)
        #expect(objectItems.properties.contains(name: "id"))
        #expect(objectItems.properties.contains(name: "name"))
        #expect(objectItems.properties[key: "id"]?.type is OpenAPIIntegerType)
        #expect(objectItems.properties[key: "name"]?.type is OpenAPIStringType)

        // Response 204 vorhanden
        let resp204 = try #require(postOp.response(httpstatus: "204"))
        #expect(resp204.description == "No Content")
    }
}
