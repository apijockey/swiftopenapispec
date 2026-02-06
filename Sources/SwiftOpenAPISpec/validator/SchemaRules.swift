/* Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//
//  Created by Patric Dubois on 02.01.2026.
//
// A small starter pack of schema-level rules that work well with a large invalid-spec corpus.

public protocol SchemaRule : Sendable {
    var name: String { get }
    func check(schema: OpenAPISchema,  ctx: ValidationContext,pointer: String) -> [Diagnostic]

}

/// Walk a schema tree and apply schema rules at each node.
public struct SchemaRuleRunner  : Sendable{
    public var rules: [SchemaRule]
    public var  ctx : ValidationContext
    public init(rules: [SchemaRule], ctx: ValidationContext) {
        self.rules = rules
        self.ctx = ctx
    }
    
    
    public func run(schema: OpenAPISchema, pointer: String,resolver: inout JSONPointerResolver) async throws -> [Diagnostic] {
        if let type =  schema.type {
            var out: [Diagnostic] = []
            out.append(contentsOf: rules.flatMap { $0.check(schema: schema, ctx: ctx, pointer: pointer) })
            
            // Recurse into schemaType (if no $ref on wrapper)
            
                if case let .object(obj) = type {
                    for prop in obj.properties {
                        if let key = prop.key{
                            let p = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                            try await out.append(contentsOf: run(schema: prop , pointer: p,resolver: &resolver))
                        }
                        
                    }
                }
                
            if case let .array(arr) = type ,
                let items = arr.items {
                        try await out.append(contentsOf: run(schema: items, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), ""),resolver: &resolver))
        
                }
                
            if case let .anyOf(openAPIAnyOfType) = type,
               let items = openAPIAnyOfType.items {
                    for (idx, item) in items.enumerated() {
                        try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "\(idx)"),resolver: &resolver))
                    }
                    
                }
                
            if case let .oneOf(openAPIAnyOfType) = type ,
               let items = openAPIAnyOfType.items {
                    for (idx, item) in items.enumerated() {
                        try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "\(idx)"),resolver: &resolver))
                    }
                    
                }
                
            if case let .allOf(openAPIAnyOfType) = type,
               let items = openAPIAnyOfType.items {
                    for (idx, item) in items.enumerated() {
                        try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "\(idx)"),resolver: &resolver))
                    }
                    
                }
                
                
            
            if case  .ref = type {
               return out
            }
            return out
        }
       return []
    }
   
    public static func defaultRunner(ctx: ValidationContext) -> SchemaRuleRunner  {
        var rules = [SchemaRule]()
        if ctx.dialect == .oas30  {
            rules.append(SupportedFormatsRule())
            rules.append(MultipleOfRule())
            rules.append(OAS30SupportedTypeRule())
            rules.append(RequiredSubsetOfPropertiesRule())
            rules.append(OneAnyAllMustHaveObjectArrayCompositionRule())
            rules.append(NonEmptyCompositionRule())
            
        }
        else {
            rules.append(StringMinMaxLengthRule())
            rules.append(RequiredSubsetOfPropertiesRule())
            rules.append(OAS30SupportedTypeRule())
            rules.append(OneAnyAllMustHaveObjectArrayCompositionRule())
            rules.append(NonEmptyCompositionRule())
        }
        return SchemaRuleRunner(rules: rules, ctx: ctx)
    }
}
/// Rule: anyOf/oneOf/allOf must contain at least one item.
public struct NonEmptyCompositionRule: SchemaRule {
    
    
    public let name = "Schema.AnyOneAllWithObjectArray"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        
        var diags: [Diagnostic] = []
        
        if case let .anyOf(ofType) = schema.type,
            (ofType.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "anyOf must contain an array of objects.",
                pointer: JSONPointer.join(pointer, "anyOf"),
                rule: name
            ))
        }
        
        if case let .oneOf(ofType) = schema.type,
            (ofType.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "oneOf must contain an array of objects.",
                pointer: JSONPointer.join(pointer, "oneOf"),
                rule: name
            ))
        }
        
        if case let .allOf(ofType) = schema.type,
           (ofType.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "allOf must contain an array of objects.",
                pointer: JSONPointer.join(pointer, "allOf"),
                rule: name
            ))
        }
        
        return diags
    }
   
}


/// Rule: anyOf/oneOf/allOf must contain at least one item.
public struct OneAnyAllMustHaveObjectArrayCompositionRule: SchemaRule {
    
    
    public let name = "Schema.OneAnyAllMustHaveObjectArray"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        
        var diags: [Diagnostic] = []
        
        if case let .anyOf(ofType) = schema.type {
            for item in ofType.items  ?? [] {
                if case .object =  item.type { }
                else {
                    diags.append(.init(
                        severity: .error,
                        code: .schemaViolation,
                        message: "anyOf elements must be of type 'object'",
                        pointer: JSONPointer.join(pointer, "anyOf"),
                        rule: name
                    ))
                }
            }
        }
           
        
        if case let .oneOf(ofType) = schema.type {
            for item in ofType.items  ?? [] {
                if case .object =  item.type { }
                else {
                    diags.append(.init(
                        severity: .error,
                        code: .schemaViolation,
                        message: "oneOf elements must be of type 'object'",
                        pointer: JSONPointer.join(pointer, "oneOf"),
                        rule: name
                    ))
                }
            }
        }
        
        if case let .allOf(ofType) = schema.type {
            for item in ofType.items  ?? [] {
                if case .object =  item.type { }
                else {
                    diags.append(.init(
                        severity: .error,
                        code: .schemaViolation,
                        message: "allOf elements must be of type 'object'",
                        pointer: JSONPointer.join(pointer, "allOf"),
                        rule: name
                    ))
                }
            }
        }
        
        return diags
    }
}

/// Rule: for strings, minLength <= maxLength (when both present).
public struct StringMinMaxLengthRule: SchemaRule {
    public let name = "Schema.StringMinMaxLength"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case  .string = schema.type  else { return [] }
        guard let min = schema.minLength,
            let max = schema.maxLength else { return [] }
        if min > max {
            return [.init(
                severity: .error,
                code: .invalidValue,
                message: "minLength (\(min)) must be <= maxLength (\(max)).",
                pointer: pointer,
                rule: name
            )]
        }
        return []
    }
}

public struct MultipleOfRule: SchemaRule {
    public let name = "Schema.MultipleOf"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case .number = schema.type,
            schema.multipleOf != nil else {
            return []
        }
        if let doubleValue =  schema.multipleOf,
           doubleValue > 0 {
            return []
        }
        return [.init(
            severity: .error,
            code: .invalidValue,
            message: "The value of 'multipleOf' MUST be strictly greater than 0",
            pointer: JSONPointer.join(pointer,"multipleOf"),
            rule: name
        )]
    }
}

public struct OAS30SupportedRegexRule: SchemaRule {
    public let name = "Schema.SupportedTypes"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        
        return []
    }
}

public struct OAS30SupportedTypeRule: SchemaRule {
    public let name = "Schema.SupportedTypes"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        
        
        if case .null = schema.type {
            return [.init(severity: .error, code: .invalidType,
                          message: "'null' type not supported in OpenAPI 3.0 (switch to nullable)",
                          pointer: "\(pointer)/type",
                          rule: "Schema.SupportedTypes")]
        }
        else if case .unknown(let type) = schema.type {
            return [.init(severity: .error, code: .invalidType,
                          message: "type '\(type)' not supported or not recognized in OpenAPI 3.0",
                          pointer: "\(pointer)/type",
                          rule: "Schema.SupportedTypes")]
        }
        return []
    }
}




/// Rule: for objects, every entry in required must exist as a property key.
public struct RequiredSubsetOfPropertiesRule: SchemaRule {
    public let name = "Schema.RequiredSubsetOfProperties"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        guard case let .object(openAPIObjectType) = schema.type else {
            return []
        }
        let required = openAPIObjectType.required
        if required.isEmpty { return [] }
        
        let propKeys = Set(openAPIObjectType.properties.map { $0.key })
        
        for r in required where !propKeys.contains(r) {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "Object marks '\(r)' as required, but no such property exists.",
                pointer: JSONPointer.join(pointer, "required"),
                rule: name
            ))
        }
        return diags
    }
}

/// Rule: for objects, every entry in required must exist as a property key.
public struct SupportedFormatsRule: SchemaRule {
    public let name = "Schema.SupportedFormat"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        
        if case .string = schema.type {
            if ["byte","binary","", "date","date-time ","password"].contains(schema.format)  || schema.format == nil { return [] }
            else {
                diags.append(Diagnostic(severity: .warning, code: .invalidValue, message: "format '\(schema.format ?? "")' not predefined for 'string'", pointer: pointer, rule: name))
            }
        }
        else if case .integer = schema.type {
            if  ["int32","int64"].contains(schema.format) || (schema.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .invalidValue, message: "format '\(schema.format ?? "")' not predefined for 'integer'", pointer: pointer, rule: name))
            }
        }
            
        else if case  .number = schema.type {
        if  ["float","double"].contains(schema.format) || (schema.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .invalidValue, message: "format '\(schema.format ?? "")' not predefined for 'String'", pointer: pointer, rule: name))
            }
        }
        else {
            if !(schema.format ?? "").isEmpty {
                diags.append(Diagnostic(severity: .warning, code: .invalidValue, message: "format '\(schema.format ?? "")' not expected", pointer: pointer, rule: name))
            }
        }
        
        return diags
    }
}

