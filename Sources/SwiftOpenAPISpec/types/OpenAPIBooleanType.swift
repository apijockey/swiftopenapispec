//
//  OpenAPIDoubleType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 22.01.26.
//


public struct OpenAPIBooleanType : OpenAPISchemaType, ThrowingHashMapInitiable, PointerNavigable  {
    public var discriminator: OpenAPIDiscriminator?
    
    public var nullable: Bool?
    
    public var readOnly: Bool?
    
    public var writeOnly: Bool?
    
    public var xml: OpenAPIXMLObject?
    
    public var externalDocs: OpenAPIExternalDocumentation?
    
    public var example: OpenAPIExample?
    
    public var deprecated: Bool?
    
    public var extensions: OpenAPIExtension?
    
    public static let TYPE_KEY = "type"
    public init(load map: StringDictionary) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    
    public let type : String?
    public var ref: OpenAPISchemaReference? { nil}
    
    public func element(for segmentName: String) throws -> Any? {
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIDoubleType", segmentName)
    }
    
    
    
   
}
