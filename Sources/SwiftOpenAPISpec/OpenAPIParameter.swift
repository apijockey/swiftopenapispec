//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

struct OpenAPIParameter :  ThrowingHashMapInitiable{
    static let NAME_KEY = "name"
    static let IN_KEY = "in"
    static let REQUIRED_KEY = "required"
    static let DESCRIPTION_KEY = "description"
    static let DEPRECATED_KEY = "deprecated"
    static let ALLOW_EMPTYVALUE_KEY = "allowEmptyValue"
    static let ALLOW_RESERVED_KEY = "allowReserved"
    static let SCHEMA_KEY = "schema"
    static let STYLE_KEY = "style"
    static let EXPLODE_KEY = "explode"
    static let EXAMPLE_KEY = "example"
    static let EXAMPLES_KEY = "examples"
    static let CONTENT_KEY = "content"
    init(_ map: [AnyHashable : Any]) throws {
        
        guard let name = map[Self.NAME_KEY] as? String  else {
            throw OpenAPISpec.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.NAME_KEY)
        }
        guard let location = map[Self.IN_KEY] as? String  else {
            throw OpenAPISpec.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.IN_KEY)
        }
        guard let required = map[Self.REQUIRED_KEY] as? Bool else {
            throw OpenAPISpec.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.REQUIRED_KEY)
        }
        self.location = location
        self.required = required
        self.name = name
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, Bool.self)
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, Bool.self)
        self.schema = try map.tryMapIfPresent(Self.SCHEMA_KEY, OpenAPISchema.self)
        self.style = map.readIfPresent(Self.STYLE_KEY, String.self)
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, Bool.self)
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, Bool.self)
        self.example = map.readIfPresent(Self.EXAMPLE_KEY, String.self)
        self.examples = try map.tryOptionalList(Self.EXAMPLES_KEY, root: "parameters", OpenAPIExample.self)
        self.content = map.readIfPresent(Self.CONTENT_KEY, OpenAPIMediaType.self)
       
    }
    var name : String? = nil
    let location : String
    let required : Bool
    var description : String? = nil
    var deprecated : Bool? = nil
    var allowEmptyValue : Bool? = nil
    var schema : OpenAPISchema? = nil
    var style : String? = nil
    var explode : Bool? = nil
    var allowReserved : Bool? = nil
    var example : Any? = nil
    var examples : [OpenAPIExample]? = []
    var content : OpenAPIMediaType? = nil
   
    //TODO: Examples Object
   
}
