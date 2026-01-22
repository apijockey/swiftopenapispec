//
//  OpenAPIDoubleType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 22.01.26.
//


public struct OpenAPIBooleanType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable, PointerNavigable  {
    public static let TYPE_KEY = "type"
    public init(_ map: StringDictionary) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    
    public let type : String?
    public var ref: OpenAPISchemaReference? { nil}
    
    public func element(for segmentName: String) throws -> Any? {
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIDoubleType", segmentName)
    }
    
    
    
    public func validate() throws {
        
    }
}
