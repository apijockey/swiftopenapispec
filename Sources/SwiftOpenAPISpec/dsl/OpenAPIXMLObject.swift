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
//  Created by Patric Dubois on 16.12.25.
//

public struct OpenAPIXMLObject : PointerNavigable, ThrowingHashMapInitiable {
   
    
    public enum NodeKind: String, Codable, Sendable {
        case element, attribute, text, cdata, none
    }
    public static let NODETYPE_KEY = "nodeType"
    public static let NAME_KEY = "name"
    public static let NAMESPACE_KEY = "namespace"
    public static let PREFIX_KEY = "prefix"
    public static let ATTRIBUTE_KEY = "attribute"
    public static let WRAPPED_KEY = "wrapped"
    
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
        let nodeType = map.readIfPresent(Self.NODETYPE_KEY,valueType:  String.self)
        self.nodeType = NodeKind(rawValue: nodeType ?? "none")
        self.name = map.readIfPresent(Self.NAME_KEY, valueType: String.self)
        self.namespace = map.readIfPresent(Self.NAMESPACE_KEY, valueType: String.self)
        self.prefix = map.readIfPresent(Self.PREFIX_KEY, valueType: String.self)
        self.attribute = map.readIfPresent(Self.ATTRIBUTE_KEY,valueType:  Bool.self)
        self.wrapped = map.readIfPresent(Self.WRAPPED_KEY,valueType:  Bool.self)
        self.extensions = try OpenAPIExtension.extensionElements(map)
    }
   
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.NODETYPE_KEY :
            let value = try JSONValue( nodeType)
            return .value(value)
        case Self.NAME_KEY :return .value(JSONValue( name))
        case Self.NAMESPACE_KEY : return .value(JSONValue( namespace))
        case Self.PREFIX_KEY :return .value(JSONValue( prefix))
        case Self.ATTRIBUTE_KEY :
            let value = try JSONValue( attribute)
            return .value(value)
        case Self.WRAPPED_KEY :
            let value = try JSONValue( wrapped)
            return .value(value)
        default:
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIXMLObject", segmentName)
        }
    }
    public var nodeType : NodeKind?
    public var name : String?
    public var namespace : String?
    public var prefix : String?
    public var attribute : Bool?
    public var wrapped : Bool?
    
    public var extensions : [OpenAPIExtension]?
    public var ref: OpenAPISchemaReference? { nil}
    
}
