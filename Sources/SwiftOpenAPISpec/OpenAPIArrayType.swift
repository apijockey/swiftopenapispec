//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIArrayType : OpenAPIValidatableSchemaType, PointerNavigable{
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.ITEMS_KEY: return self.items
        case Self.ARRAY_TYPE_KEY: return self.type
        case Self.MAX_ITEMS_KEY : return maxItems
        case Self.ITEMS_KEY : return items
        case Self.MIN_ITEMS_KEY : return minItems
        case Self.UNIQE_ITEMS_KEY : return uniqueItems
        case Self.MAX_CONTAINS_KEY : return maxContains
        case Self.MIN_CONTAINS_KEY : return minContains
        default:  throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIArrayType", segmentName)
                    }
    }
    
    
    public static let TYPE_KEY = "array"
    public static let ARRAY_TYPE_KEY = "type"
    public static let MAX_ITEMS_KEY = "maxItems"
    public static let ITEMS_KEY = "items"
    public static let MIN_ITEMS_KEY = "minItems"
    public static let UNIQE_ITEMS_KEY = "uniqueItems"
    public static let MAX_CONTAINS_KEY = "maxContains"
    public static let MIN_CONTAINS_KEY = "minContains"
    
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        self.minItems = map[Self.MIN_ITEMS_KEY] as? Int
        self.maxItems = map[Self.MAX_ITEMS_KEY] as? Int
        self.maxContains = map[Self.MAX_CONTAINS_KEY] as? Int
        self.minContains = map[Self.MIN_CONTAINS_KEY] as? Int
        self.uniqueItems = map[Self.UNIQE_ITEMS_KEY] as? Bool
        if let items = map[Self.ITEMS_KEY] as? [String : Any],
           let type = items[Self.ARRAY_TYPE_KEY] as? String,
            let validatableType = OpenAPISchemaType.validatableType(type) {
                self.items = try validatableType.init(items)
           
        }
        
        
    }
    
    public func validate() throws {
        
    }
    public let type : String?
    public var maxItems : Int?
    public var minItems : Int?
    public var uniqueItems : Bool?
    public var maxContains : Int?
    public var minContains : Int?
    public var items: OpenAPIValidatableSchemaType?
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var ref: OpenAPISchemaReference? { nil}
}
