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
//  Created by Patric Dubois on 10.12.25.
//

public struct OpenAPITag:  KeyedElement, PointerNavigable {
   
    public func element(for segmentName: String) throws -> NavigationResult{
        switch segmentName {
        case Self.NAME_KEY: return .value(JSONValue(key))
        case Self.SUMMARY_KEY : return .value(JSONValue(summary))
        case Self.DESCRIPTION_KEY : return .value(JSONValue(description))
            case Self.EXTERNAL_DOCS_KEY : return .navigable(externalDocs)
            case Self.PARENT_KEY : return .value(JSONValue(parent))
            case Self.KIND_KEY : return .value(JSONValue(kind))
        default:
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPITag", segmentName)

        }
    }
    
   
    
    //REQUIRED
    public static let NAME_KEY = "name"
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let EXTERNAL_DOCS_KEY = "externalDocs"
    public static let PARENT_KEY = "parent"
    public static let KIND_KEY = "kind"
    
    
   

    public init(load map: StringDictionary,diagnostics: inout [Diagnostic]) throws {
        self.key = map.readIfPresent(Self.NAME_KEY, valueType: String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, valueType: String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self)
        self.parent = map.readIfPresent(Self.PARENT_KEY, valueType: String.self)
        self.kind = map.readIfPresent(Self.KIND_KEY, valueType: String.self)
        self.externalDocs = try map.readIfPresent(Self.EXTERNAL_DOCS_KEY, objectType: OpenAPIExternalDocumentation.self, diagnostics: &diagnostics)
        self.extensions = try OpenAPIExtension.extensionElements(map, &diagnostics)
    }
    
   
    //https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-01  ("null", "boolean", "object", "array", "number", or "string"), or "integer"
    public var key : String?
    public var summary : String?
    public var description : String?
    public var externalDocs : OpenAPIExternalDocumentation?
    public var parent : String?
    public var kind : String?
   
    public var extensions : [OpenAPIExtension]?
  
}
public extension Array where Element == OpenAPITag {
    subscript (name name: String) -> OpenAPITag? {
        return self.first(where: { $0.key == name })
    }
}
