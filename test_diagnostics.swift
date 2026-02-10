#!/usr/bin/swift

import Foundation
import SwiftOpenAPISpec

// Test-Diagnostics erstellen
let diagnostics = [
    Diagnostic(severity: .error, code: .invalidRef, message: "Invalid reference found", pointer: "/paths/get", rule: "ReferenceResolutionRule"),
    Diagnostic(severity: .warning, code: .missingRequired, message: "Required field missing", pointer: "/components/schemas/User", rule: "SchemaValidationRule"),
    Diagnostic(severity: .info, code: .debugTrace, message: "Debug information", pointer: "/info", rule: "DebugRule"),
    Diagnostic(severity: .error, code: .schemaViolation, message: "Schema violation detected", pointer: "/paths/post", rule: "VeryLongRuleNameThatExceedsFortyCharacters"),
    Diagnostic(severity: .warning, code: .invalidValue, message: "Invalid value in parameter", pointer: "/paths/get", rule: "ParameterValidationRule")
]

// Ausgabe der Diagnostics
print("Diagnostics Output:")
print(diagnostics.description)
