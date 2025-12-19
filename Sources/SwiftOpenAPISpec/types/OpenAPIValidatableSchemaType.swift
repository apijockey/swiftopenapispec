//
//  OpenAPIValidatableSchemaTypes.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public  protocol OpenAPIValidatableSchemaType : ThrowingHashMapInitiable {
    func validate() throws
    
}
