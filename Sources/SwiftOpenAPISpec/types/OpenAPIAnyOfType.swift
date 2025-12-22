//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIAnyOfType : OpenAPIValidatableSchemaType, PointerNavigable {
    public static func == (lhs: OpenAPIAnyOfType, rhs: OpenAPIAnyOfType) -> Bool {
        guard lhs.type == rhs.type else { return false }
        switch (lhs.items, rhs.items) {
        case (nil, nil):
            return true
        case let (l?, r?):
            guard l.count == r.count else { return false }
            for (le, re) in zip(l, r) {
                if !le.isEqual(to: re) { return false }
            }
            return true
        default:
            return false
        }
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public static let TYPE_KEY = "anyOf"
   
    public init(types :[OpenAPIValidatableSchemaType]) {
        self.items = types as? [any OpenAPIValidatableSchemaType]
        self.type = "anyOf"
    }
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
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIAnyOfType",segmentName)
    }
    public let type : String?
    public var items: [any OpenAPIValidatableSchemaType]?
    
}
