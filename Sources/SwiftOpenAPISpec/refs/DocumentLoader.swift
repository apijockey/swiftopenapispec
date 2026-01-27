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
//
//  Created by Patric Dubois on 15.12.25.
//
import Foundation
import Yams

/**
 Used in ``OpenAPISpecification`` to read referenced Yaml/JSON files when referenced by a JSONPointer.
 
 This package provides a default implementation with ``YamsDocumentLoader`` using the Yams package.
 */
public protocol DocumentLoadable : Sendable{
    func load(from url: URL) async throws -> OpenAPISpecification
}


/// Default implementation for the ``DocumentLoadable`` protocol which is a required parameter.
public actor YamsDocumentLoader : DocumentLoadable {
    private var objectCash: [URL: OpenAPISpecification] = [:]
    
    /// inits an instance of the object.
    ///
    /// The YamsDocumentLoader keeps an internal map of urls to OpenAPISpecifications and loads the contents of an OpenAPI specification using the Yams package.
    public init() {
        
    }
    public enum Errors : CustomStringConvertible, LocalizedError {
        public var description: String{
            switch self {
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            
            }
        }
        
        case unreadable(String, Error)
        case notUTF8(String)
        public var errorDescription: String? {
            return description
        }
    }
    
    public func load(from url: URL) async throws -> OpenAPISpecification {
        do {
            var diagnostics = [Diagnostic]()
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8) else {
                throw Self.Errors.notUTF8(url.absoluteString)
            }
            let unflattened = try Yams.load(yaml: string) as? StringDictionary
            guard let unflattened = unflattened else {
                throw OpenAPISpecification.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
            }
            var apiSpec = try OpenAPISpecification(load: unflattened, &diagnostics)
            apiSpec.documentLoader = self
            objectCash[url] = apiSpec
            return apiSpec
        } catch {
            throw Self.Errors.unreadable(url.absoluteString, error)
        }
    }
}
