////
////  ValidationIssue.swift
////  openapigenerator
////
////  Created by Patric Dubois on 19.12.25.
////
//
//
//import JSONSchema
//
//public struct ValidationIssue: Equatable {
//    public enum Severity { case warning, error }
//    public let severity: Severity
//    public let message: String
//    public let pointer: String
//}
//
//public final class RequestValidator {
//    private let schemaConverter = SchemaConverter()
//
//    public init() {}
//
//    public func validateGeneratedRequest(
//        operation: ImportedOperation,
//        generated: GeneratedRequest
//    ) -> [ValidationIssue] {
//
//        var issues: [ValidationIssue] = []
//
//        // 1) required params check
//        for p in operation.parameters where p.required {
//            if !generated.hasParameter(p) {
//                issues.append(.init(
//                    severity: .error,
//                    message: "Missing required parameter \(p.name)",
//                    pointer: "parameters.\(p.location).\(p.name)"
//                ))
//            }
//        }
//
//        // 2) body schema check (nur JSON in v1)
//        if let body = generated.jsonBody,
//           let variant = operation.requestBodies.preferredJSONVariant {
//
//            do {
//                let jsonSchema = try schemaConverter.toJSONSchema(variant.schemaContext)
//                let validator = Validator(schema: jsonSchema)
//                let result = validator.validate(instance: body)
//                for err in result.errors {
//                    issues.append(.init(
//                        severity: .error,
//                        message: err.localizedDescription,
//                        pointer: "requestBody"
//                    ))
//                }
//            } catch {
//                issues.append(.init(
//                    severity: .warning,
//                    message: "Schema validation skipped: \(error)",
//                    pointer: "requestBody"
//                ))
//            }
//        }
//
//        return issues
//    }
//}
