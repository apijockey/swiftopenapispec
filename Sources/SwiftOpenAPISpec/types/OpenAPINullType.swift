//
//  OpenAPIStringType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//


public struct OpenAPIStringType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable , PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case Self.FORMAT_KEY : return format
            case Self.MAXLENGTH_KEY : return maxLength
            case Self.MINLENGTH_KEY : return minLength
            case Self.PATTERN_KEY : return pattern
            case Self.TYPE_KEY : return type
            case Self.ALLOWED_ELEMENTS_KEY : return allowedElements
            case OpenAPISchemaReference.REF_KEY : return ref
        default:
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIStringType", segmentName)

        }
        
    }
    
   
    
    
    public static let FORMAT_KEY : String = "format"
    public static let MAXLENGTH_KEY = "maxLength"
    public static let MINLENGTH_KEY = "minLength"
    public static let PATTERN_KEY = "pattern"
    public static let TYPE_KEY = "type"
    public static let ALLOWED_ELEMENTS_KEY = "enum"
    
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        if let allowedElements = map[Self.ALLOWED_ELEMENTS_KEY] as? [String] {
            self.allowedElements = Set(allowedElements)
        } else {
            self.allowedElements = nil
        }
        self.maxLength = map[Self.MAXLENGTH_KEY] as? Int
        self.minLength = map[Self.MINLENGTH_KEY] as? Int
        self.pattern = map[Self.PATTERN_KEY] as? String
        self.format = map.readIfPresent(Self.FORMAT_KEY, String.self)
    }
   
    public func validate() throws {
        
    }
    public var format : String?
    public let type : String?
    public let allowedElements : Set<String>?
    public let maxLength: Int?
    public let minLength: Int?
    public let pattern: String?
   
    public var ref: OpenAPISchemaReference? { nil}
}
