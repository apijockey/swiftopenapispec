//
//  OpenAPIXMLObject.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 16.12.25.
//

public struct OpenAPIXMLObject : PointerNavigable {
    public enum NodeKind: String, Codable {
        case element, attribute, text, cdata, none
    }
    public static let NODETYPE_KEY = "nodeType"
    public static let NAME_KEY = "name"
    public static let NAMESPACE_KEY = "namespace"
    public static let PREFIX_KEY = "prefix"
    public static let ATTRIBUTE_KEY = "attribute"
    public static let WRAPPED_KEY = "wrapped"
    
    
    public init(_ map: [String : Any]) throws {
        let nodeType = map.readIfPresent(Self.NODETYPE_KEY, String.self)
        self.nodeType = NodeKind(rawValue: nodeType ?? "none") 
        self.name = map.readIfPresent(Self.NAME_KEY, String.self)
        self.namespace = map.readIfPresent(Self.NAMESPACE_KEY, String.self)
        self.prefix = map.readIfPresent(Self.PREFIX_KEY, String.self)
        self.attribute = map.readIfPresent(Self.ATTRIBUTE_KEY, Bool.self)
        self.wrapped = map.readIfPresent(Self.WRAPPED_KEY, Bool.self)
        self.extensions = try OpenAPIExtension.extensionElements(map)
            
    }
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.NODETYPE_KEY : return nodeType
        case Self.NAME_KEY :return name
        case Self.NAMESPACE_KEY : return namespace
        case Self.PREFIX_KEY :return prefix
        case Self.ATTRIBUTE_KEY : return attribute
        case Self.WRAPPED_KEY : return wrapped
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
