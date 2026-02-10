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

//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/// A structure representing a path in an OpenAPI specification and its associated operations.
///
/// `OpenAPIPathItem` represents a single path in an API (e.g., `/users`, `/products/{id}`)
/// and contains the HTTP operations (GET, POST, PUT, etc.) that can be performed on that path.
///
/// Each path item can have multiple operations, each corresponding to a different HTTP method.
/// The structure also includes path-level metadata like summary, description, and parameters
/// that apply to all operations on this path.
///
/// ## Features
///
/// - **Operation Access**: Provides convenient subscript access to filter operations by HTTP method
/// - **Path Parameters**: Contains parameters that apply to all operations on this path
/// - **Metadata**: Includes summary and description for documenting the path
/// - **Servers**: Can specify alternative servers for this specific path
///
/// ## Example Usage
///
/// ```swift
/// // Accessing a specific operation on a path
/// if let getOperation = pathItem[.get] {
///     print("GET operation found: \(getOperation.summary ?? "No summary")")
/// }
/// ```
public struct OpenAPIPathItem: KeyedElement , PointerNavigable {
   
    
    public enum Operations: String, Codable {
        case get, post, put, delete, options, head, patch, trace, query
    }
    
   
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let SERVERS_KEY = "servers"
    public static let PARAMETERS_KEY = "parameters"
    public static let ADDITIONAL_OPERATIONS_KEY = "additionalOperations"
    
    /// holds the relative path to an individual endpoint, beginning with a leading slash
    /// ```swift
    /// //example
    /// "/ping"
    /// inits an instance of ``OpenAPIPath``
    /// - Parameter map: Swift dictionary with a Path key and  value elements representing HTTP methods like **GET**, **POST** and **PUT**
    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String) throws {
        // one resource may foresee several httpOperations
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        
        
        for (key, httpOperation) in map {
            if Self.Operations(rawValue: key) != nil,
               case let .object(dictionary) = httpOperation {
                
                var operation = try OpenAPIOperation(load: dictionary, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, "\(key)"))
                operation.key = key
                self.operations.append(operation)
            }
            else {
                if key != Self.SUMMARY_KEY,
                   key != Self.DESCRIPTION_KEY,
                   key != OpenAPISchemaReference.REF_KEY,
                   key != Self.SERVERS_KEY,
                   key != Self.PARAMETERS_KEY,
                   !key.starts(with: "x-") {
                    let description = "Key \(key) in PathItem is not a valid HTTP method or a valid Path element"
                    let diagnostic = Diagnostic(severity:  .error, code: .invalidValue , message: description, pointer: JSONPointer.join(pointer, "\(key)"), rule: "OAS.SupportedHTTPMethodRule")
                    diagnostics.append(diagnostic)
                }
            }
        
        }
       
        self.summary  = map.readIfPresent(Self.SUMMARY_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.SUMMARY_KEY))
        self.description  = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        let servers = try map.mapListIfPresent(OpenAPISpecification.SERVERS_KEY, objectType: OpenAPIServer.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISpecification.SERVERS_KEY))
        if servers.count > 0 {
            self.servers = servers
        }
        let parameters = try map.mapListIfPresent(Self.PARAMETERS_KEY, objectType: OpenAPIParameter.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.PARAMETERS_KEY))
        if parameters.count > 0 {
            self.parameters = parameters
        }
        self.additionalOperations = try map.mapListIfPresent(Self.ADDITIONAL_OPERATIONS_KEY, valueType: OpenAPIOperation.self, pointer: JSONPointer.join(pointer, Self.ADDITIONAL_OPERATIONS_KEY))
        self.extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
    }
   
    public func element(for segmentName: String) throws -> NavigationResult{
        switch segmentName {
           
        case Self.SUMMARY_KEY: return .value(JSONValue(summary))
            case Self.DESCRIPTION_KEY: return .value(JSONValue(description))
        case Self.SERVERS_KEY:
            let value = servers.first(where: { $0.key == segmentName })
            return .navigable(value)
        case Self.PARAMETERS_KEY: return .navigableCollection(self.parameters)
        case Self.ADDITIONAL_OPERATIONS_KEY: return try additionalOperations.element(for: segmentName)
        case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
            default :
            if let operation = operations[key: segmentName] {
                return .navigable(operation)
            }
            if segmentName.hasPrefix("x-") {
                  if let ext = extensions.first(where: { $0.key == segmentName }) {
                      let value = try JSONValue(ext)
                      return .value(value)
                      
                  }
              }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIPathItem", segmentName)
        }
    }
    // Zugriff per HTTP-Methode (get, post, put, ...) -> Liste oder nil
    public subscript(httpMethod method: String) -> [OpenAPIOperation] {
        let matches = operations.filter { $0.key == method }
        return matches.isEmpty ? [] : matches
    }

    // Zugriff per operationId -> Liste oder nil
    public subscript(operationId id: String) -> [OpenAPIOperation] {
        let matches = operations.filter { $0.operationId == id }
        return matches.isEmpty ? [] : matches
    }
    public var additionalOperations: [OpenAPIOperation] = []
    public var description :String? = nil
    public var key: String? = nil
    public var extensions : [OpenAPIExtension] = []
    public var operations: [OpenAPIOperation] = []
    public var parameters: [OpenAPIParameter] = []
    public var ref : OpenAPISchemaReference? = nil
    public var servers: [OpenAPIServer] = []
    public var summary: String? = nil
  
}


public extension Array where Element == OpenAPIPathItem  {
    // Zugriff per HTTP-Methode (get, post, put, ...) -> Liste oder nil
    subscript(httpMethod method: String) -> [OpenAPIOperation] {
        var matches : [OpenAPIOperation] = []
        for element in self {
            matches.append(contentsOf: element[httpMethod: method])
        }
        return matches.isEmpty ? [] : matches
        
    }

    /// Access an ``OpenAPIOperation`` based on its unique  ``OpenAPIOperation/operationId``.
     subscript(operationID id : String) -> [OpenAPIOperation] {
        var matches : [OpenAPIOperation] = []
        for element in self {
            matches.append(contentsOf: element[operationId: id])
        }
        return matches.isEmpty ? [] : matches
        
    }
    /// search for a **path** declaration
     ///
    /// An OpenAPI specification may hold a list of **Path** elements. The subscript provides an easy access to a list of matching ``OpenAPIPathItem`` elements for that **path** string.
    ///
    /// - Parameters: an OpenApi path item string, starting with a slash.
    /// - Returns: a list of  OpenAPIPath structs matching the search **path** string
    ///
    /// ```swift
    /// // sample search for the Path declaration for /ping
    ///  let openAPIPath = apiSpec[path: "/ping"]
    /// ```
    ///
    subscript(path path: String) -> OpenAPIPathItem? {
        return self.first(where: { $0.key == path })
    }
   
    
   
}
