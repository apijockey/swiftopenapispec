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

/*
 * Copyright 2025 
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
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/// Helper struct which maps  a Yaml-List / JSON-Array to Swift-Array
public struct HashmapInitializableList<T> where T : ThrowingHashMapInitiable {
    
    /// Creates a list of elements from a Yaml-List / JSON-Array 
    /// - Parameter a Yaml-List / JSON-Array
    /// - Returns: a Swift Array or  throws an error if any element  of type `T` cannot be created
    static func map(_ list:  [Any]) throws -> InitializationResult<[T]> {
        var diagnostics: [Diagnostic] = []
        var types = [T]()
        for element in list {
            if let elementMap = element as? StringDictionary {
                let element = try T.initialize(elementMap)
                diagnostics.append(contentsOf: element.diagnostics)
                types.append(element.value)
            }
        }
        return InitializationResult(value: types, diagnostics: diagnostics)
    }
    
}




public protocol JSONPointerResolvable {
    func resolveSubscript(key : String) -> String?
}

public struct InitializationResult<T> {
    public var value: T
    public let diagnostics: [Diagnostic]
}
public protocol ThrowingHashMapInitiable : Sendable {
    static func initialize(_ map : StringDictionary) throws -> InitializationResult<Self>
   
   
}
/**A KeyedElement expects that the key Value is set from outside**/

public struct RelativeReferenceResolver {
    
    var specMap : [URL:OpenAPISpecification] = [URL:OpenAPISpecification]()
    enum Errors : LocalizedError {
        case invalidURL(String)
    }
    private let baseURL : String
    private let baseSpec : OpenAPISpecification
    public static func resolve(_ url: String, baseUrl: String) throws -> URL {
        guard let baseURL = URL(string: baseUrl),
        let resolvedURL = URL(string: url, relativeTo: baseURL)else {
            throw Self.Errors.invalidURL("\(url) \(baseUrl)")
        }
        return resolvedURL
        
    }
    
    public init(baseURL: String, baseSpec: OpenAPISpecification) {
        self.baseURL = baseURL
        self.baseSpec = baseSpec
    }
    public func resolve<T>(component type  : T.Type, from reference : String) throws -> T? {
        if reference.hasPrefix("#"){
            // load from localFile
            return nil
        }
        else if reference.hasPrefix("./") {
            // load from relative file
            return nil
        }
        return nil
        
    }
    /// sehr einfache Fragment-Auflösung für "#/components/schemas/User"
        func resolveFragment(root: [String: Any], fragment: String) throws -> Any {
            let trimmed = fragment.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let keys = trimmed.split(separator: "/").map(String.init)

            var current: Any = root
            for key in keys {
                guard let dict = current as? [String: Any] else {
                    throw Validator.Errors.resolveError("Expected dict at \(key)")
                    
                }
                guard let next = dict[key] else {
                    throw Validator.Errors.resolveError("Key \(key) not found")
                    
                }
                current = next
            }
            return current
        }
   
}


