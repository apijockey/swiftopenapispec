//
//  File.swift
//
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIMediaType :  KeyedElement , PointerNavigable {
    public static let SCHEMA_KEY = "schema"
    public static let ITEM_SCHEMA_KEY = "itemSchema"
    public static let EXAMPLES_KEY = "examples"
    public static let EXAMPLE_KEY = "example"
    public static let ENCODING_KEY = "encoding"
    public static let PREFIX_ENCODING_KEY = "prefixEncoding"
    public static let ITEM_ENCODING_KEY = "itemEncoding"
    public static let EXTENSIONS_KEY = "extensions"
    public var key : String?
    public init(_ map: [String : Any]) throws {
        
            if let schemaMap = map[Self.SCHEMA_KEY] as? StringDictionary {
                self.schema  = try OpenAPISchema(schemaMap)
            }
            if let schemaMap = map[Self.ITEM_SCHEMA_KEY] as? StringDictionary {
                self.schema  = try OpenAPISchema(schemaMap)
            }
             
            
            if let examplesMap  = map[Self.EXAMPLES_KEY]  as? StringDictionary{
                self.examples = try KeyedElementList.map(examplesMap)
            }
            if let subMap = map[Self.ENCODING_KEY] as? StringDictionary {
                encoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
            }
            if let subMap = map[Self.PREFIX_ENCODING_KEY] as? StringDictionary {
                prefixEncoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
            }
            if let subMap = map[Self.PREFIX_ENCODING_KEY] as? StringDictionary {
                itemEncoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
            }
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                    self.ref = try OpenAPISchemaReference(refMap)
                }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
            }
            
        
    }
    
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.SCHEMA_KEY:
            return self.schema
        case Self.EXAMPLES_KEY:
            return self.examples
        case Self.ENCODING_KEY: return encoding
        case Self.PREFIX_ENCODING_KEY: return prefixEncoding
        case Self.ITEM_ENCODING_KEY: return itemEncoding
        case OpenAPISchemaReference.REF_KEY: return ref
        default:
            if self.key == segmentName { return self.schema }
            throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIMediaType", segmentName)
        }
    }
    public var schema : OpenAPISchema? = nil
    public var itemSchema : OpenAPISchema? = nil
    public var examples : [OpenAPIExample] = []
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var encoding :[OpenAPIEncoding]? = nil
    public var prefixEncoding :[OpenAPIEncoding]? = nil
    public var itemEncoding :[OpenAPIEncoding]? = nil
    public var ref : OpenAPISchemaReference? = nil
    //ENCODING
}

