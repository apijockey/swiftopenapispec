//
//  File.swift
//  
//
//  Created by Patric Dubois on 28.03.24.
//

import Foundation


public struct OpenAPISchemaProperty: KeyedElement {
    
    
    static let TYPE_KEY = "type"
    
    public init(_ map: [String : Any]) throws {
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPISchemaType.validatableType(type) {
            self.type = try validatableType.init(map)
        }
        else if map[OpenAPISchema.JSONREF_KEY] is String {
            self.type = try OpenAPIValidatableType(map)
            
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
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public  var key : String? = nil
    public var type : OpenAPIValidatableSchemaType?
    public var discriminator : OpenAPIDiscriminator?
    
}



