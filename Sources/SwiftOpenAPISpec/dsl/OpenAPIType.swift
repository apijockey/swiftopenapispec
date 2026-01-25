//
//  OpenAPIType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 24.01.26.
//


public indirect enum OpenAPIType: ThrowingHashMapInitiable {
   
    
    case allOf(OpenAPIAllOfType)
    case anyOf(OpenAPIAnyOfType)
    case array(OpenAPIArrayType)
    case bool(OpenAPIBooleanType)
    case integer(OpenAPIIntegerType)
    case number(OpenAPINumberType)
    case object(OpenAPIObjectType)
    case oneOf(OpenAPIOneOfType)
    case string(OpenAPIStringType)
    case ref(OpenAPISchemaReference)
    case null(OpenAPINullType)
    
    static let NULLABLE_KEY = "nullable"
    public static let TYPE_KEY = "type"
    public static let ONEOF_KEY = "oneOf"
    public static let ANYOF_KEY = "anyOf"
    public static let XML_KEY = "xml"
    public static let ALLOF_KEY = "allOf"
    public static let DISCRIMINATOR_KEY = "discriminator"
    public static let FORMAT_KEY = "format"
    public init() {
        self = .null(OpenAPINullType())
    }
    public static func initialize(_ map: StringDictionary) throws -> InitializationResult<OpenAPIType> {
        if let reference = try OpenAPISchemaReference.initReference(from: (map)) {
            let ref  =  OpenAPIType.ref(reference)
            return InitializationResult(value: ref, diagnostics: [])
        }
      
        let type = map.readIfPresent(Self.TYPE_KEY, String.self)
        switch type {
                case "string":
                    let type = try OpenAPIType.string(OpenAPIStringType(load: map))
                    return  InitializationResult(value:type, diagnostics: [])

                    case "number":
                        let type = try OpenAPIType.number(OpenAPINumberType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case "integer":
                        let type = try OpenAPIType.integer(OpenAPIIntegerType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case "array":
                        let type = try OpenAPIType.array(OpenAPIArrayType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case "object":
                        let type = try OpenAPIType.object(OpenAPIObjectType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case "boolean":
                        let type = try OpenAPIType.bool(OpenAPIBooleanType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case "null":
                        let type = try OpenAPIType.null(OpenAPINullType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case .none:
                    let diagnostic = Diagnostic(severity: .error, code: .missingRequired, message: "no type info", pointer: "", rule: "Initialization.OpenAPIType")
                    let nullType = try OpenAPINullType(load: map)
                    let type = OpenAPIType.null(nullType)
                    return  InitializationResult(value:type, diagnostics: [diagnostic])

                    default:
                    let diagnostic = Diagnostic(severity: .error, code: .missingRequired, message: "no type info", pointer: "", rule: "Initialization.OpenAPIType")
                    let nullType = try OpenAPINullType(load: map)
                    let type = OpenAPIType.null(nullType)
                    return  InitializationResult(value:type, diagnostics: [diagnostic])
                    }
         

    }
    public func element(for segmentName : String) throws -> Any? {
        // switch segmentName {
        
        switch self {
        case .allOf(let openAPIAllOfType):
            return openAPIAllOfType
        case .anyOf(let openAPIAnyOfType):
            return openAPIAnyOfType
        case .array(let openAPIArrayType):
            return try openAPIArrayType.element(for: segmentName)
        case .bool(let openAPIBooleanType):
            return try openAPIBooleanType.element(for: segmentName)
        case .integer(let openAPIIntegerType):
            return try openAPIIntegerType.element(for: segmentName)
        case .number(let openAPINumberType):
            return try openAPINumberType.element(for: segmentName)
        case .object(let openAPIObjectType):
            return try openAPIObjectType.element(for: segmentName)
        case .oneOf(let openAPIOneOfType):
            return openAPIOneOfType
        case .string(let openAPIStringType):
            return try openAPIStringType.element(for: segmentName)
        case .ref(let openAPISchemaReference):
            return openAPISchemaReference
        case .null(let openAPINullType):
            return openAPINullType
        }
        
        
    }
          
       

}

