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
    case unknown(String)
    
    static let NULLABLE_KEY = "nullable"
    public static let TYPE_KEY = "type"
    public static let ONEOF_KEY = "oneOf"
    public static let ANYOF_KEY = "anyOf"
    public static let XML_KEY = "xml"
    public static let ALLOF_KEY = "allOf"
    
    public init() {
        self = .null
    }
    
    public init(load map: StringDictionary,  diagnostics: inout [Diagnostic],pointer : String) throws {
        // Handle $ref first
        if let reference =  try map.readIfPresent(OpenAPISchemaReference.REF_KEY, objectType: OpenAPISchemaReference.self, diagnostics: &diagnostics, pointer: pointer) {
            self = .ref(reference)
            return
        }
        
        let type = map.readIfPresent(Self.TYPE_KEY, valueType: String.self, diagnostics : &diagnostics, pointer:  pointer)
        switch type {
        case .some("string"):
            self = .string

        case .some("number"):
            self = .number

        case .some("integer"):
            self = .integer

        case .some("array"):
            let arrayType = try OpenAPIArrayType(load: map, diagnostics : &diagnostics, pointer: pointer)
            self = .array(arrayType)

        case .some("object"):
            let objectType = try OpenAPIObjectType(load: map, diagnostics: &diagnostics, pointer : pointer)
            self = .object(objectType)

        case .some("boolean"):
            self = .bool
                   
        case .some("null"):
            self = .null
        default:
            if map.readIfPresent(OpenAPISchemaReference.REF_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: pointer) != nil{
                let ref = try OpenAPISchemaReference(load: map, diagnostics: &diagnostics,pointer :pointer)
                   self = .ref(ref)
                   return
            }
            // Try composite constructs if type is missing
            if let oneOfValue = map[OpenAPIOneOfType.TYPE_KEY],
                case .array  = oneOfValue  {
                let pointer = JSONPointer.join(pointer, "oneOf")
                var localDiagnostics: [Diagnostic] = []
                let oneOf = try OpenAPIOneOfType(load: map, diagnostics: &localDiagnostics,pointer : pointer)
                diagnostics.append(contentsOf: localDiagnostics)
                self = .oneOf(oneOf)
                return
            }
           
            if let oneOfValue = map[OpenAPIAnyOfType.TYPE_KEY],
                case .array  = oneOfValue  {
                let pointer = JSONPointer.join(pointer, "oneOf")
                // OpenAPIAnyOfType has a different initializer style
                let anyOf = try OpenAPIAnyOfType(load: map,  &diagnostics, pointer: pointer)
                self = .anyOf(anyOf)
                return
            }
            if let oneOfValue = map[OpenAPIAllOfType.TYPE_KEY],
                case .array  = oneOfValue  {
                let pointer = JSONPointer.join(pointer, "allOf")
                let allOf = try OpenAPIAllOfType(load: map, diagnostics: &diagnostics,pointer : pointer)
                self = .allOf(allOf)
                return
            }
            
            // Unsupported or missing type info
            let diagnostic = Diagnostic(
                severity: .error,
                code: .missingRequired,
                message: "unsupported or missing type info",
                pointer: pointer,
                rule: "Initialization.OpenAPIType"
            )
            diagnostics.append(diagnostic)
            self = .unknown(type ?? "")
        }
        
        let supportingElments = Set(Self.supportedKeys)
        
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: supportingElments , pointer: pointer))
        
    }
    
    /// The set of keys supported by OpenAPI Type object (excluding dynamic extensions)
    private static var supportedKeys: Set<String> {
        [
            Self.TYPE_KEY,
            Self.ONEOF_KEY,
            Self.ANYOF_KEY,
            Self.ALLOF_KEY,
            Self.XML_KEY,
            Self.NULLABLE_KEY,
            OpenAPISchemaReference.REF_KEY
        ]
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
        case .unknown(_):
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIType", segmentName)
        }
    }
}
extension  OpenAPIType : CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .allOf:
            return "allOf"
        case .anyOf:
            return "anyOf"
        case .array:
            return "array"
        case .bool:
            return "bool"
        case .integer:
            return "integer"
        case .number:
            return "number"
        case .object:
            return "object"
        case .oneOf:
            return "oneOf"
        case .string:
            return "string"
        case .ref(let openAPISchemaReference):
            return "ref(\(openAPISchemaReference.reference ?? ""))"
        case .null:
            return "null"
        case .unknown(let string):
            return "unknown(\(string))"
        }
    }
}
extension Optional where Wrapped == OpenAPIType {
    public var debugDescription: String {
        if let wrapped = self {
            return wrapped.debugDescription
        } else {
                return "nil"
        }
    }
    
}
