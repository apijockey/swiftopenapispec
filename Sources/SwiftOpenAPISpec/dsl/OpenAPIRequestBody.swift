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


//  Created by Patric Dubois on 29.03.24.
//

import Foundation
/// A structure representing the request body of an OpenAPI operation.
///
/// `OpenAPIRequestBody` defines the structure and content of the body that can be sent
/// with an HTTP request. It specifies the media types, schemas, and other metadata
/// related to the request payload.
///
/// Request bodies are used in operations that send data to the server, such as POST,
/// PUT, and PATCH operations. They describe what data the client should send and
/// in what format.
///
/// ## Key Components
///
/// - `description`: A description of the request body
/// - `required`: Whether the request body is required (default: false)
/// - `contents`: The media types and schemas that define the structure of the request body
///
/// ## Example Usage
///
/// ```swift
/// // Creating a JSON request body
/// let requestBody = OpenAPIRequestBody(
///     description: "User data to create",
///     required: true,
///     contents: [
///         OpenAPIMediaType(
///             mediaType: "application/json",
///             schema: OpenAPISchema(schemaType: OpenAPIObjectType(...))
///         )
///     ]
/// )
/// ```
public struct OpenAPIRequestBody : KeyedElement , PointerNavigable {
   
    public static let DESCRIPTION_KEY = "description"
    public static let REQUIRED_KEY = "required"
    public static let CONTENTS_KEY = "content"
    /// Creates an `OpenAPIRequestBody` instance from a dictionary representation.
    ///
    /// - Parameters:
    ///   - map: A dictionary containing the OpenAPI request body data
    ///   - diagnostics: An array to collect any diagnostic messages during parsing
    ///   - pointer: A JSON pointer indicating the location in the source document
    /// - Throws: An error if the input data is invalid or required fields are missing
    ///
    /// This initializer can handle both direct request body definitions and references to request bodies
    /// defined in the components section of the OpenAPI specification.
    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String)  throws {
        
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        self.contents = try map.mapListIfPresent(Self.CONTENTS_KEY, objectType: OpenAPIMediaType.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.CONTENTS_KEY))
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        
        self.required = map.readIfPresent(Self.REQUIRED_KEY, valueType: Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.REQUIRED_KEY)) ?? false
        
    }
   

    public var key : String?
    
    public var description : String? = nil
    public var required : Bool = false
    public var contents : [OpenAPIMediaType] = []
   
    public var ref : OpenAPISchemaReference? = nil
    /// Navigates to a specific element within the request body structure.
    ///
    /// - Parameter segmentName: The name of the element to navigate to
    /// - Returns: A `NavigationResult` containing either the requested value or a navigable element
    /// - Throws: An error if the requested element does not exist
    public func element(for segmentName : String) throws -> NavigationResult {
        switch segmentName {
        case Self.CONTENTS_KEY : .navigableCollection(contents)
            default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIRequestBody", segmentName)
        }
    }
    
}

