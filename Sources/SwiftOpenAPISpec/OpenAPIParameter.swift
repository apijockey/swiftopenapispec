//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/**
 /**
  A unique parameter is defined by a combination of a name and location.
  */
 */
public struct OpenAPIParameter :  ThrowingHashMapInitiable{
    public enum ParameterLocation : String, Codable, CaseIterable {
        case cookie, query, queryString, header ,path
    }
    public enum ParameterStyle : String, Codable, CaseIterable {
        case simple,form, label, matrix
    }
    public static let FORMAT_KEY = "format"
    public static let NAME_KEY = "name"
    public static let IN_KEY = "in"
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
    public init(_ map: [String: Any]) throws {
        
        guard let name = map[Self.NAME_KEY] as? String  else {
            throw OpenAPIObject.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.NAME_KEY)
        }
        guard let location = map[Self.IN_KEY] as? String  else {
            throw OpenAPIObject.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.IN_KEY)
        }
        //required
        self.content = map.readIfPresent(Self.CONTENT_KEY, OpenAPIMediaType.self)
        self.schema = try map.MapIfPresent(Self.SCHEMA_KEY, OpenAPISchema.self)
        if self.content == nil && self.schema == nil {
            self
        }
        let required = map[Self.REQUIRED_KEY] as? Bool
        self.required = required ?? false
        
        
        self.location = ParameterLocation(rawValue: location)
        self.name = name
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, Bool.self)
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, Bool.self)
        
        if let style = map.readIfPresent(Self.STYLE_KEY, String.self) {
            self.style = ParameterStyle(rawValue: style)
        }
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, Bool.self)
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, Bool.self)
        self.example = map.readIfPresent(Self.EXAMPLE_KEY, String.self)
        self.examples = try map.tryOptionalList(Self.EXAMPLES_KEY, root: "parameters", OpenAPIExample.self)
        
        self.format = map.readIfPresent(Self.FORMAT_KEY, String.self)
       
    }
    public var name : String? = nil
    public let location : ParameterLocation?
    public let required : Bool
    public var description : String? = nil
    public var deprecated : Bool? = nil
    public var allowEmptyValue : Bool? = nil
    public var schema : OpenAPISchema? = nil
    //https://learn.openapis.org/specification/parameters.html
    public var style : ParameterStyle? = nil
    public var explode : Bool? = nil
    public var allowReserved : Bool? = nil
    public var example : Any? = nil
    public var examples : [OpenAPIExample]? = []
    public var content : OpenAPIMediaType? = nil
    public var format : String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
   
    //TODO: Examples Object
   
}
