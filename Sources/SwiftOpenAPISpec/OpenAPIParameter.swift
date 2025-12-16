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
public struct OpenAPIParameter :  KeyedElement, PointerNavigable {
    
    
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
        
      
        guard let location = map[Self.IN_KEY] as? String  else {
            throw OpenAPIObject.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.IN_KEY)
        }
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, Bool.self)
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, Bool.self)
        //required
        self.content = map.readIfPresent(Self.CONTENT_KEY, OpenAPIMediaType.self)
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, Bool.self)
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, Bool.self)
       
        self.example = map.readIfPresent(Self.EXAMPLE_KEY, String.self)
        self.format = map.readIfPresent(Self.FORMAT_KEY, String.self)
        
        if let examplesMap  = map[Self.EXAMPLES_KEY]  as? StringDictionary{
            self.examples = try KeyedElementList.map(examplesMap)
        }
        extensions = try OpenAPIExtension.extensionElements(map)
        self.location = ParameterLocation(rawValue: location)
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                    self.ref = try OpenAPISchemaReference(refMap)
        }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
        } 
        let required = map[Self.REQUIRED_KEY] as? Bool
        self.required = required ?? false
        self.schema = try map.MapIfPresent(Self.SCHEMA_KEY, OpenAPISchema.self)
        if let style = map.readIfPresent(Self.STYLE_KEY, String.self) {
            self.style = ParameterStyle(rawValue: style)
        }
        
       
       
       
    }
    public func element(for segmentName: String) throws -> Any? {
       switch segmentName {
        case Self.IN_KEY :return location?.rawValue
       case Self.REQUIRED_KEY : return required
       case Self.DESCRIPTION_KEY: return description
       case Self.DEPRECATED_KEY: return deprecated
       case Self.ALLOW_EMPTYVALUE_KEY: return allowEmptyValue
       case Self.ALLOW_RESERVED_KEY: return allowReserved
       case Self.SCHEMA_KEY: return schema
       case Self.STYLE_KEY: return style
       case Self.EXPLODE_KEY: return explode
       case Self.EXAMPLE_KEY: return example
       case Self.EXAMPLES_KEY: return examples
       case Self.CONTENT_KEY: return content
       case OpenAPISchemaReference.REF_KEY: return ref
       default:
           if segmentName.hasPrefix("x-"), let exts = extensions {
                           if let ext = exts.first(where: { $0.key == segmentName }) {
                               // Gib die strukturierte oder einfache Extension zurück
                               return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
                           }
                       }
           throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIParameter", segmentName)
        }
    }
    public var key: String?
    public var ref : OpenAPISchemaReference? = nil
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
    public var extensions : [OpenAPIExtension]?
   
    //TODO: Examples Object
   
}
