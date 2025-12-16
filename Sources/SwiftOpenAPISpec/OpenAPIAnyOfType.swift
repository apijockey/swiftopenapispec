//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIAnyOfType : OpenAPIValidatableSchemaType, PointerNavigable {
    public var ref: OpenAPISchemaReference? { nil}
    
    public static let TYPE_KEY = "anyOf"
   
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        guard let list = (map["anyOf"] as? [Any]) else {
            return
        }
        self.items = try list.asValidatableSchemaType()
        
        
    }
    
    public func validate() throws {
        
    }
    public func element(for segmentName: String) throws -> Any? {
        if let index = Int(segmentName) {
            return self.items?[index]
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return ref
        }
        throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIAnyOfType",segmentName)
    }
    public let type : String?
    public var items: [OpenAPIValidatableSchemaType]?
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
