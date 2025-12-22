//
//  OpenAPIStringType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//


public struct OpenAPINullType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable , PointerNavigable {
    public func validate() throws {
        
    }
    
    public init(_ map: StringDictionary) throws {
        
    }
    public init () {
        
    }
    public var ref: OpenAPISchemaReference?
    
    public func element(for segmentName: String) throws -> Any? {
      
          
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPINullType", segmentName)

        
    }
    
   
    
    
   
}
