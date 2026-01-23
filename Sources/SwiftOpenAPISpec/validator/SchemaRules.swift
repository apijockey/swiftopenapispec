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
    func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic]

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
        var out: [Diagnostic] = []
        out.append(contentsOf: rules.flatMap { $0.check(schemaType: schema, pointer: JSONPointer.join(pointer,"type")) })
        
        // Recurse into schemaType (if no $ref on wrapper)
        if schema.ref == nil {
            if let obj = schema.objectType {
                for prop in obj.properties {
                    if let key = prop.key,
                       let schemaType = prop.type{
                        let p = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                        try await out.append(contentsOf: run(schema: schemaType , pointer: p,resolver: &resolver))
                    }
                    
                }
            }
            
            if let arr = schema.arrayType, let items = arr.items {
                for (idx, item) in items.enumerated() {
                    try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "\(idx)"),resolver: &resolver))
                }
                
            }
            
            if let arr = schema.anyOf, let items = arr.items {
                for (idx, item) in items.enumerated() {
                    try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "\(idx)"),resolver: &resolver))
                }
                
            }
            
            if let arr = schema.oneOf, let items = arr.items {
                for (idx, item) in items.enumerated() {
                    try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "\(idx)"),resolver: &resolver))
                }
                
            }
            
            if let arr = schema.allOf, let items = arr.items {
                for (idx, item) in items.enumerated() {
                    try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "\(idx)"),resolver: &resolver))
                }
                
            }
            
            
            return out
            
        }
        else if let ref = schema.ref,
                let anyType = try await resolver.resolve(ref: ref.refString) as? OpenAPISchema {
            let results = try await run(schema: anyType, pointer: pointer,resolver: &resolver)
            out.append(contentsOf:  results)
        }
        return out
    }
    public static func defaultRunner(ctx: ValidationContext) -> SchemaRuleRunner  {
        var rules = [SchemaRule]()
        if ctx.dialect == .oas30  {
            rules.append(SupportedFormatsRule())
            rules.append(MultipleOfRule())
            rules.append(OAS30SupportedTypeRule())
            rules.append(RequiredSubsetOfPropertiesRule())
        }
        else {
            rules.append(StringMinMaxLengthRule())
            rules.append(RequiredSubsetOfPropertiesRule())
            rules.append(OAS30SupportedTypeRule())
        }
        return SchemaRuleRunner(rules: rules, ctx: ctx)
        
        
    }
  
}

/// Rule: anyOf/oneOf/allOf must contain at least one item.
public struct NonEmptyCompositionRule: SchemaRule {
    public let name = "Schema.NonEmptyComposition"
    public init() {}
    
    public func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic] {
        
        var diags: [Diagnostic] = []
        
        if let anyOf = schemaType.anyOf, (anyOf.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "anyOf must contain at least one schema.",
                pointer: JSONPointer.join(pointer, "anyOf"),
                rule: name
            ))
        }
        
        if let oneOf = schemaType.oneOf, (oneOf.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "oneOf must contain at least one schema.",
                pointer: JSONPointer.join(pointer, "oneOf"),
                rule: name
            ))
        }
        
        if let allOf = schemaType.allOf, (allOf.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "allOf must contain at least one schema.",
                pointer: JSONPointer.join(pointer, "allOf"),
                rule: name
            ))
        }
        
        return diags
    }
}

/// Rule: for strings, minLength <= maxLength (when both present).
public struct StringMinMaxLengthRule: SchemaRule {
    public let name = "Schema.StringMinMaxLength"
    public init() {}
    
    public func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic] {
        guard let t = schemaType.stringType else { return [] }
        guard let min = t.minLength, let max = t.maxLength else { return [] }
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
    
    public func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic] {
        guard let t = schemaType.numberType else { return [] }
        if let doubleValue =  t.multipleOf,
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
    
    public func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic] {
        
        return []
    }
}

public struct OAS30SupportedTypeRule: SchemaRule {
    public let name = "Schema.SupportedTypes"
    public init() {}
    
    public func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic] {
        
        if let t = (schemaType.integerType) {
            return [.init(severity: .error, code: .invalidType,
                          message: "unknown type '\(t.type ?? "")'",
                          pointer: "\(pointer)/\("type")",
                          rule: "Schema.SupportedTypes")]
        }
        else if schemaType.nullable {
            return [.init(severity: .error, code: .invalidType,
                          message: "Null type not supported in OpenAPI 3.0 (switch to nullable)",
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
    
    public func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic] {
        guard let obj = schemaType.objectType else { return [] }
        let required = obj.required
        if required.isEmpty { return [] }
        
        let propKeys = Set(obj.properties.map { $0.key })
        var diags: [Diagnostic] = []
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
    
    public func check(schemaType: OpenAPISchema, pointer: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        
        if let stringType =  schemaType.stringType  {
            if ["byte","binary","", "date","date-time ","password"].contains(stringType.format)  || stringType.format == nil { return [] }
            else {
                diags.append(Diagnostic(severity: .warning, code: .invalidValue, message: "format not predefined for 'string'", pointer: pointer, rule: name))
            }
        }
        if let arrayType = schemaType.arrayType {
            return []
        }
        if let integerType = schemaType.integerType {
            if  ["int32","int64"].contains(integerType.format) || (integerType.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .invalidValue, message: "format '\(integerType.format ?? "")' not predefined for 'integer'", pointer: pointer, rule: name))
            }
        }
            
        if let numberType = schemaType.numberType {
            if  ["float","double"].contains(numberType.format) || (numberType.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .invalidValue, message: "format '\(numberType.format ?? "")' not predefined for 'String'", pointer: pointer, rule: name))
            }
        }
        
        return diags
    }
}

