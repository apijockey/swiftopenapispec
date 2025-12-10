//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIMediaType :  KeyedElement {
    public static let SCHEMA_KEY = "schema"
    public static let EXAMPLE_KEY = "example"
    public static let EXAMPLES_KEY = "examples"
    public var key : String?
    public init(_ map: [AnyHashable : Any]) throws {
        if map[Self.SCHEMA_KEY] != nil {
            let schemaMap = try map.tryRead(Self.SCHEMA_KEY, [AnyHashable:Any].self, root: "content")
            self.schema =  try OpenAPISchema(schemaMap)
        self.schemaRef =  try OpenAPISchemaReference(schemaMap)
        self.oneOfSchemas = try OneOfSchemas(schemaMap)
        self.examples = try map.mapListIfPresent(Self.EXAMPLES_KEY)
            
        }
    }
    public var schema : OpenAPISchema? = nil
    public var schemaRef  : OpenAPISchemaReference? = nil
    public var oneOfSchemas : OneOfSchemas? = nil
    public var examples : [OpenAPIKeyedExample] = []
    public var userInfos =  [OpenAPISpec.UserInfo]()
    //EXAMPLE
    
    //ENCODING
}

public extension Array where Element == OpenAPIMediaType  {
    
    subscript (mediaType type: String) -> OpenAPIMediaType? {
        return first { response in
            response.key == type
        }
    }
    
}
