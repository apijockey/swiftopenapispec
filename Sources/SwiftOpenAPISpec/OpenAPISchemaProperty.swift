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
            let validatableType = OpenAPIDefaultSchemaType.validatableType(type) {
            self.type = try validatableType.init(map)
        }
        else if map[OpenAPISchema.JSONREF_KEY] is String {
            self.type = try OpenAPIValidatableComponentType(map)
            
        }
        else if map[OpenAPISchema.ONEOF_KEY] is [Any] {
            self.type = try OpenAPIValidatableOneOfType(map)
        }
        else if map[OpenAPISchema.ANYOF_KEY] is [Any] {
            self.type = try OpenAPIValidatableAnyOfType(map)
        }
        else if map[OpenAPISchema.ALLOF_KEY] is [Any] {
            self.type = try OpenAPIValidatableAllOfType(map)
        }
        if let discriminatorMap = map[OpenAPISchema.DISCRIMINATOR_KEY] as? [String : Any] {
            self.discriminator = try OpenAPIValidatableDiscriminator(discriminatorMap)
        }
   
    }
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public  var key : String? = nil
    public var type : OpenAPIValidatableSchemaType?
    public var discriminator : OpenAPIValidatableDiscriminator?
    
}



