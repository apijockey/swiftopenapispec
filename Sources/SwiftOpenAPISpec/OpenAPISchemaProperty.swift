//
//  File.swift
//  
//
//  Created by Patric Dubois on 28.03.24.
//

import Foundation


public struct OpenAPISchemaProperty: KeyedElement , PointerNavigable {
    
    
    static let TYPE_KEY = "type"
    
    public init(_ map: [String : Any]) throws {
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPISchemaType.validatableType(type) {
            self.type = try validatableType.init(map)
        }
        else if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
            self.ref = try OpenAPISchemaReference(refMap)
            
           
        }
        else if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
        }
        else if map[OpenAPISchema.ONEOF_KEY] is [Any] {
            self.type = try OpenAPIOneOfType(map)
        }
        else if map[OpenAPISchema.ANYOF_KEY] is [Any] {
            self.type = try OpenAPIAnyOfType(map)
        }
        else if map[OpenAPISchema.ALLOF_KEY] is [Any] {
            self.type = try OpenAPIAllOfType(map)
        }
        if let discriminatorMap = map[OpenAPISchema.DISCRIMINATOR_KEY] as? [String : Any] {
            self.discriminator = try OpenAPIDiscriminator(discriminatorMap)
        }
   
    }
    public var userInfos =  [OpenAPISpecification.UserInfo]()
    public  var key : String? = nil
    public var ref : OpenAPISchemaReference?
    public var type : OpenAPIValidatableSchemaType?
    public var discriminator : OpenAPIDiscriminator?
    
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
            case OpenAPISchemaReference.REF_KEY : return self.type
            case Self.TYPE_KEY : return self.type
            case OpenAPISchema.ONEOF_KEY: return type
            case OpenAPISchema.ALLOF_KEY : return type
            case OpenAPISchema.DISCRIMINATOR_KEY : return self.discriminator
            
            default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISchema", segmentName)
        }
    }
    
}



