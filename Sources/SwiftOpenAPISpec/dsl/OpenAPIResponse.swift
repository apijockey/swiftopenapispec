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


/// A structure representing a response in an OpenAPI operation.
///
/// `OpenAPIResponse` defines the structure of a response that an API operation can return.
/// Each response is associated with an HTTP status code (e.g., "200", "404", "500")
/// and describes the response body, headers, and other metadata.
///
/// Responses are essential for documenting what clients can expect from API operations,
/// including success cases, error cases, and the structure of returned data.
///
/// ## Key Components
///
/// - `description`: A description of the response (required)
/// - `content`: The media types and schemas of the response body
/// - `headers`: Response headers that may be included
/// - `links`: Links to related operations or resources
/// - `summary`: A short summary of the response
///
/// ## Example Usage
///
/// ```swift
/// // Creating a successful response
/// let successResponse = OpenAPIResponse(
///     key: "200",
///     description: "Successful operation",
///     content: [
///         OpenAPIMediaType(
///             mediaType: "application/json",
///             schema: OpenAPISchema(schemaType: OpenAPIObjectType(...))
///         )
///     ]
/// )
/// ```
public struct OpenAPIResponse : KeyedElement, PointerNavigable {
    public static let DESCRIPTION_KEY = "description"
    public static let SUMMARY_KEY = "summary"
    public static let CONTENT_KEY = "content"
    public static let HEADERS_KEY = "headers"
    public static let LINKS_KEY = "links"
    /// Creates an `OpenAPIResponse` instance from a dictionary representation.
    ///
    /// - Parameters:
    ///   - map: A dictionary containing the OpenAPI response data
    ///   - diagnostics: An array to collect any diagnostic messages during parsing
    ///   - pointer: A JSON pointer indicating the location in the source document
    /// - Throws: An error if the input data is invalid or required fields are missing
    ///
    /// This initializer can handle both direct response definitions and references to responses
    /// defined in the components section of the OpenAPI specification.
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
     
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType:  String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.SUMMARY_KEY))
        self.content = try map.mapListIfPresent(Self.CONTENT_KEY, objectType: OpenAPIMediaType.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.CONTENT_KEY))
        self.headers = try map.mapListIfPresent(Self.HEADERS_KEY, objectType: OpenAPIHeader.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.HEADERS_KEY))
        self.links =   try map.mapListIfPresent(Self.LINKS_KEY, objectType: OpenAPILink .self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.LINKS_KEY))
        let supportingElments = Set(Self.supportedKeys)
        
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: supportingElments , pointer: pointer))
    }
   
    public static var supportedKeys: [String] { [
        Self.CONTENT_KEY,
        Self.DESCRIPTION_KEY,
        Self.HEADERS_KEY,
        Self.LINKS_KEY,
        Self.SUMMARY_KEY
    ] }
    
    public var summary : String?
    public var description : String?
    public var content: [OpenAPIMediaType] = []
    public var headers: [OpenAPIHeader] = []
    public var links : [OpenAPILink] =   []
    public var key : String? = nil
    public var ref : OpenAPISchemaReference? = nil
   
    
    public func element(for segmentName : String) throws -> NavigationResult{
        switch segmentName {
        case Self.CONTENT_KEY: return  .navigableCollection(self.content)
        case Self.DESCRIPTION_KEY : return .value(JSONValue(description))
        case Self.HEADERS_KEY: return .navigableCollection(self.headers)
        case Self.LINKS_KEY: return  .navigableCollection(self.links)
             
        case Self.SUMMARY_KEY: return .value(JSONValue(self.summary))
        case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
        default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIResponse", segmentName)
        }
    }
}


