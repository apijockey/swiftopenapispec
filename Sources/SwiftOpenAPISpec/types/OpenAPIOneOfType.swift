//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIOneOfType : OpenAPIValidatableSchemaType,PointerNavigable {
    public static func == (lhs: OpenAPIOneOfType, rhs: OpenAPIOneOfType) -> Bool {
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
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOneOfType",segmentName)
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
    public var items: [any OpenAPIValidatableSchemaType]?
  
    public var ref: OpenAPISchemaReference? { nil}
}
