//
//  File.swift
//
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIHeader :  KeyedElement, PointerNavigable {


    public static let REQUIRED_KEY = "required"
    public static let DESCRIPTION_KEY = "description"
    public static let DEPRECATED_KEY = "deprecated"
    public static let ALLOW_EMPTYVALUE_KEY = "allowEmptyValue"
    public static let ALLOW_RESERVED_KEY = "allowReserved"
    public static let SCHEMA_KEY = "schema"
    public static let STYLE_KEY = "style"
    public static let EXPLODE_KEY = "explode"
    public static let EXAMPLE_KEY = "example"
    public static let EXAMPLES_KEY = "examples"
    public static let CONTENT_KEY = "content"
    public init(_ map: [String : Any]) throws {
        
      
        self.required = map.readIfPresent(Self.REQUIRED_KEY, Bool.self) ?? false
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, Bool.self)
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, Bool.self)
        self.schema = try map.MapIfPresent(Self.SCHEMA_KEY, OpenAPISchema.self)
        self.style = map.readIfPresent(Self.STYLE_KEY, String.self)
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, Bool.self)
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, Bool.self)
        self.example = map.readIfPresent(Self.EXAMPLE_KEY, String.self)
        
        if let examplesMap  = map[Self.EXAMPLES_KEY]  as? StringDictionary{
            self.examples = try KeyedElementList.map(examplesMap)
        }
        self.content = map.readIfPresent(Self.CONTENT_KEY, OpenAPIMediaType.self)
        extensions = try OpenAPIExtension.extensionElements(map)
       
    }
    public func element(for segmentName: String) throws -> Any? {
        try Self.element(for: segmentName)
    }
    public var key: String?
    public let required : Bool
    public var description : String? = nil
    public var deprecated : Bool? = nil
    public var allowEmptyValue : Bool? = nil
    public var schema : OpenAPISchema? = nil
    public var style : String? = nil
    public var explode : Bool? = nil
    public var ref : String? // PointerNavigable
    public var allowReserved : Bool? = nil
    public var example : Any? = nil
    public var extensions : [OpenAPIExtension]?
    public var examples : [OpenAPIExample]? = []
    public var content : OpenAPIMediaType? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
   
    //TODO: Examples Object
   
}

