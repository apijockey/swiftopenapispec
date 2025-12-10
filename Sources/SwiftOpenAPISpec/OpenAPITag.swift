//
//  OpenAPITag.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//

public struct OpenAPITag:  ThrowingHashMapInitiable {
    
    //REQUIRED
    public static let NAME_KEY = "type"
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let EXTERNAL_DOCS_KEY = "externalDocs"
    public static let PARENT_KEY = "parent"
    public static let KIND_KEY = "kind"
    
    
   
    public init(_ map : StringDictionary) throws {
        self.name = map.readIfPresent(Self.NAME_KEY, String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.parent = map.readIfPresent(Self.PARENT_KEY, String.self)
        self.kind = map.readIfPresent(Self.KIND_KEY, String.self)
        self.externalDocs = try map.mapIfPresent(Self.EXTERNAL_DOCS_KEY, OpenAPIExternalDocumentation.self)
       
    }
    
    public var schemaType : OpenAPIValidatableSchemaType?
    //https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-01  ("null", "boolean", "object", "array", "number", or "string"), or "integer"
    public var name : String?
    public var summary : String?
    public var description : String?
    public var externalDocs : OpenAPIExternalDocumentation?
    public var parent : String?
    public var kind : String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
   
    
}
