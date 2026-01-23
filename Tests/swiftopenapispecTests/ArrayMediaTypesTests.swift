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
@testable import SwiftOpenAPISpec
import Testing

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

    private func fixtureMap(_ resource: String, ext: String = "yaml", subDirectory : String? = nil) throws -> StringDictionary {
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

    @Test("String array")
    func getTagsResponseArrayOfString() async throws {
        let yaml = try fixtureMap("37-array-mediatypes", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "37-array-mediatypes", documentLoader: YamsDocumentLoader())

        let path = try #require(apiSpec[path: "/tags"])
        let getOp = try #require(path[operationId: "getTags"].first)

        let response200 = try #require(getOp.response(httpstatus: "200"))
        let media = try #require(response200.content[key: "application/json"])
        let schemaType = try #require(media.schema?.arrayType)

        // Array-Constraints
        #expect(schemaType.minItems == 1)
        // items: string
        let itemsType = try #require(schemaType.items as? OpenAPIStringType)
        #expect(itemsType.type == "string")
    }

    @Test("Object array")
    func postTagsRequestArrayOfObject() async throws {
        let yaml = try fixtureMap("37-array-mediatypes", subDirectory: "Resources/3_1/valid")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url: "37-array-mediatypes", documentLoader: YamsDocumentLoader())
       
        let path = try #require(apiSpec[path: "/tags"])
    
        let postOp = try #require(path[operationId: "createTags"].first)
       
        let reqBody = try #require(postOp.requestBody)
        let media = try #require(reqBody.contents[key: "application/json"])
       
        let schemaType = try #require(media.schema?.arrayType)
        
        // Array-Flag
        #expect(schemaType.uniqueItems == true)
        let objectItems = try #require(schemaType.items as? OpenAPIObjectType)
        
        #expect(objectItems.properties.count == 2)
        #expect(objectItems.properties.contains(name: "id"))
        #expect(objectItems.properties.contains(name: "name"))
        #expect(objectItems.properties[key: "id"]?.type is OpenAPIIntegerType)
        #expect(objectItems.properties[key: "name"]?.type is OpenAPIStringType)
        let resp204 = try #require(postOp.response(httpstatus: "204"))
        #expect(resp204.description == "No Content")
    }
}
