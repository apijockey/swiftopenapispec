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

struct APIWithExamplesTests {

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
    private func specString(_ resource: String, ext: String = "yaml", subDirectory: String? = nil) throws -> StringDictionary {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw Self.Errors.notFound(name)
        }

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string) as? StringDictionary else {
                throw Self.Errors.notUTF8(name)
            }
            return map
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
    @Test("Test OpanAPI Object")
    func minimal() async throws {
        let yaml = try specString("01-minimal-30",subDirectory: "Resources/3_0/valid")
        
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml,url:"01-minimal-30", documentLoader: YamsDocumentLoader())
        #expect(apiSpec.version == "3.0.3")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping"].first)
        #expect(getPingOperation.responses.count == 1)
    }
    

}
