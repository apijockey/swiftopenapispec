//
//  File 2.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
//superset of https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-00
//https://spec.commonmark.org
//https://spec.openapis.org/oas/3.1/dialect/base
//https://json-schema.org
//https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-00
// dialect:
//https://spec.openapis.org/oas/3.1/dialect/base
//
//https://swagger.io/docs/specification/data-models/oneof-anyof-allof-not/




struct OpenAPISchema :  ThrowingHashMapInitiable {
    enum DataType : String, CaseIterable {
        case integer, int32, int64, number, string
    }
    static let TYPE_KEY = "type"
    static let FORMAT_KEY = "format"
    static let PROPERTIES_KEY = "properties"
    static let REQUIRED_KEY = "required"
   
    init(_ map: [AnyHashable : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        self.format = DataType(rawValue:map[Self.FORMAT_KEY] as? String ?? DataType.string.rawValue)
        
        if let propertiesMap = map[Self.PROPERTIES_KEY] as? [AnyHashable:Any]{
            self.properties = try MapListMap.map(propertiesMap )
        }
        self.required = map[Self.REQUIRED_KEY] as? [String] ?? []
    }
    
    var type : String? = nil
    var format : DataType? = nil
    var properties : [OpenAPISchemaProperty] = []
    var required : [String] = []
    
}
