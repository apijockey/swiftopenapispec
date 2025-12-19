//
//  File.swift
//
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIHeader :  KeyedElement, PointerNavigable {

    public static let ALLOW_EMPTYVALUE_KEY = "allowEmptyValue"
    public static let ALLOW_RESERVED_KEY = "allowReserved"
    public static let CONTENT_KEY = "content"
    public static let DESCRIPTION_KEY = "description"
    public static let DEPRECATED_KEY = "deprecated"
    public static let EXAMPLE_KEY = "example"
    public static let EXAMPLES_KEY = "examples"
    public static let EXTENSIONS_KEY = "extensions"
    public static let EXPLODE_KEY = "explode"
    public static let REQUIRED_KEY = "required"
    public static let SCHEMA_KEY = "schema"
    public static let STYLE_KEY = "style"
   
    public init(_ map: [String : Any]) throws {
        
        
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, Bool.self)
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, Bool.self)
       
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, Bool.self)
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, Bool.self)
        self.example = map.readIfPresent(Self.EXAMPLE_KEY, String.self)
        
        if let examplesMap  = map[Self.EXAMPLES_KEY]  as? StringDictionary{
            self.examples = try KeyedElementList.map(examplesMap)
        }
        self.content = map.readIfPresent(Self.CONTENT_KEY, OpenAPIMediaType.self)
        extensions = try OpenAPIExtension.extensionElements(map)
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                   self.ref = try OpenAPISchemaReference(refMap)
               }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
                       }
        self.required = map.readIfPresent(Self.REQUIRED_KEY, Bool.self) ?? false
        self.schema = try map.MapIfPresent(Self.SCHEMA_KEY, OpenAPISchema.self)
        self.style = map.readIfPresent(Self.STYLE_KEY, String.self)
       
    }
    public func element(for segmentName: String) throws -> Any? {
       switch segmentName {
       case Self.ALLOW_EMPTYVALUE_KEY: return allowEmptyValue
       case Self.ALLOW_RESERVED_KEY: return allowReserved
       case Self.CONTENT_KEY: return content
       
       case Self.EXAMPLE_KEY: return example
       case Self.EXAMPLES_KEY: return examples
       case Self.EXPLODE_KEY: return explode
       case Self.EXTENSIONS_KEY: return extensions
       case Self.DESCRIPTION_KEY: return description
       case Self.DEPRECATED_KEY: return deprecated
       case Self.SCHEMA_KEY: return schema       
       case Self.STYLE_KEY: return style
       case OpenAPISchemaReference.REF_KEY: return ref
       default:
           // Für x-* Vendor Extensions einzelne Keys erlauben: "x-..." -> passenden Extension-Wert liefern
           if segmentName.hasPrefix("x-"), let exts = extensions {
               if let ext = exts.first(where: { $0.key == segmentName }) {
                   // Gib die strukturierte oder einfache Extension zurück
                   return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
               }
           }
           throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIHeader", segmentName)
    
       
        
        }
    }
    public var key: String?
    public let required : Bool
    public var description : String? = nil
    public var deprecated : Bool? = nil
    public var allowEmptyValue : Bool? = nil
    public var schema : OpenAPISchema? = nil
    public var style : String? = nil
    public var explode : Bool? = nil
    public var ref : OpenAPISchemaReference? = nil
    public var allowReserved : Bool? = nil
    public var example : Any? = nil
    public var extensions : [OpenAPIExtension]?
    public var examples : [OpenAPIExample]? = []
    public var content : OpenAPIMediaType? = nil
    public var userInfos =  [OpenAPISpecification.UserInfo]()
   
    //TODO: Examples Object
   
}

