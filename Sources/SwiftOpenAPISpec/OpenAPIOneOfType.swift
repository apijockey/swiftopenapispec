//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIOneOfType : OpenAPIValidatableSchemaType,PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        if let index = Int(segmentName),
           index >= 0,
           let itemsCount = self.items?.count,
           index < itemsCount{
            return self.items?[index]
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return ref
        }
        throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIOneOfType",segmentName)
    }
    
    
    public static let TYPE_KEY = "oneOf"
   
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        guard let list = (map["oneOf"] as? [Any]) else {
            return
        }
        self.items = try list.asValidatableSchemaType()
    }
    public func validate() throws {
    }
    public let type : String?
    public var items: [OpenAPIValidatableSchemaType]?
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var ref: OpenAPISchemaReference? { nil}
}
