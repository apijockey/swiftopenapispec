//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

struct OpenAPIMediaType :  KeyedElement {
    static let SCHEMA_KEY = "schema"
    static let EXAMPLE_KEY = "example"
    static let EXAMPLES_KEY = "examples"
    var key : String?
    init(_ map: [AnyHashable : Any]) throws {
        if map[Self.SCHEMA_KEY] != nil {
            let schemaMap = try map.tryRead(Self.SCHEMA_KEY, [AnyHashable:Any].self, root: "content")
            self.schema =  try OpenAPISchema(schemaMap)
        self.schemaRef =  try OpenAPISchemaReference(schemaMap)
        self.oneOfSchemas = try OneOfSchemas(schemaMap)
        self.examples = try map.mapListIfPresent(Self.EXAMPLES_KEY)
            
        }
    }
    var schema : OpenAPISchema? = nil
    var schemaRef  : OpenAPISchemaReference? = nil
    var oneOfSchemas : OneOfSchemas? = nil
    var examples : [OpenAPIKeyedExample] = []
    //EXAMPLE
    
    //ENCODING
}
