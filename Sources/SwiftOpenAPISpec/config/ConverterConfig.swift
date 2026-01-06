//
//  OpenAPIRuntimeConfig.swift
//  openapigenerator
//
//  Created by Patric Dubois on 19.12.25.
//

import Foundation


/// provides configuration information for the ``SchemaConverter``,
public struct ConverterConfig {
    public enum Dialect { case oas30, jsonSchema2020_12 }

    public var dialect: Dialect
    public var maxMergeDepth: Int = 8
    public var onUnsupported: (String) -> Void = { _ in }  // hook für warnings

    public init(dialect: Dialect = .jsonSchema2020_12) { self.dialect = dialect }
    public init() {
        self.dialect = .jsonSchema2020_12
    }
    
}
