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
    case bool
    case integer
    case number
    case object(OpenAPIObjectType)
    case oneOf(OpenAPIOneOfType)
    case string
    case ref(OpenAPISchemaReference)
    case null
    
    static let NULLABLE_KEY = "nullable"
    public static let TYPE_KEY = "type"
    public static let ONEOF_KEY = "oneOf"
    public static let ANYOF_KEY = "anyOf"
    public static let XML_KEY = "xml"
    public static let ALLOF_KEY = "allOf"
    public init() {
        self = .null
    }
    public static func initialize(_ map: StringDictionary) throws -> InitializationResult<OpenAPIType> {
        if let reference = try OpenAPISchemaReference.initReference(from: (map)) {
            let ref  =  OpenAPIType.ref(reference)
            return InitializationResult(value: ref, diagnostics: [])
        }
      
        let type = map.readIfPresent(Self.TYPE_KEY, String.self)
        switch type {
                case "string":
                    return .init(value: .string, diagnostics: [])

                    case "number":
                        return .init(value: .number, diagnostics: [])

                    case "integer":
                        return .init(value: .integer, diagnostics: [])

                    case "array":
                        let type = try OpenAPIType.array(OpenAPIArrayType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case "object":
                        let type = try OpenAPIType.object(OpenAPIObjectType(load: map))
                        return  InitializationResult(value:type, diagnostics: [])

                    case "boolean":
                            return .init(value: .bool, diagnostics: [])
                   
                    case "null":
                        return .init(value: .null, diagnostics: [])

                    default:
                    let diagnostic = Diagnostic(severity: .error, code: .missingRequired, message: "unsupported or missing type info", pointer: "", rule: "Initialization.OpenAPIType")
            
                        let type = OpenAPIType.null
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
        case .bool:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIType", segmentName)
        case .integer:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIType", segmentName)
        case .number:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIType", segmentName)
        case .object(let openAPIObjectType):
            return try openAPIObjectType.element(for: segmentName)
        case .oneOf(let openAPIOneOfType):
            return openAPIOneOfType
        case .string:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIType", segmentName)
        case .ref(let openAPISchemaReference):
            return openAPISchemaReference
        case .null:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIType", segmentName)
        }
        
        
    }
          
       

}

