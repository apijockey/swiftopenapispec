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
    
    public init(load map: StringDictionary, _ diagnostics: inout [Diagnostic]) throws {
        // Handle $ref first
        if let reference =  try map.readIfPresent(OpenAPISchemaReference.REF_KEY, objectType: OpenAPISchemaReference.self) {
            self = .ref(reference)
            return
        }
      
        let type = map.readIfPresent(Self.TYPE_KEY, valueType: String.self)
        switch type {
        case .some("string"):
            self = .string

        case .some("number"):
            self = .number

        case .some("integer"):
            self = .integer

        case .some("array"):
            let arrayType = try OpenAPIArrayType(load: map)
            self = .array(arrayType)

        case .some("object"):
            let objectType = try OpenAPIObjectType(load: map, &diagnostics)
            self = .object(objectType)

        case .some("boolean"):
            self = .bool
                   
        case .some("null"):
            self = .null

        default:
            // Try composite constructs if type is missing
            if map.readIfPresent(Self.ONEOF_KEY, valueType: [Any].self) != nil {
                var localDiagnostics: [Diagnostic] = []
                let oneOf = try OpenAPIOneOfType(load: map, &localDiagnostics)
                diagnostics.append(contentsOf: localDiagnostics)
                self = .oneOf(oneOf)
                return
            }
            if map.readIfPresent(Self.ANYOF_KEY, valueType: [Any].self) != nil {
                // OpenAPIAnyOfType has a different initializer style
                let anyOf = try OpenAPIAnyOfType(load: map,  &diagnostics)
                self = .anyOf(anyOf)
                return
            }
            if map.readIfPresent(Self.ALLOF_KEY, valueType: [Any].self) != nil {
                let allOf = try OpenAPIAllOfType(load: map, &diagnostics)
                self = .allOf(allOf)
                return
            }
            
            // Unsupported or missing type info
            let diagnostic = Diagnostic(
                severity: .error,
                code: .missingRequired,
                message: "unsupported or missing type info",
                pointer: "",
                rule: "Initialization.OpenAPIType"
            )
            diagnostics.append(diagnostic)
            self = .null
        }
    }
    
    public func element(for segmentName : String) throws -> Any? {
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
