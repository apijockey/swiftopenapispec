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
    func check(schemaType: any OpenAPIValidatableSchemaType, pointer: String) -> [Diagnostic]
}

/// Walk a schema tree and apply schema rules at each node.
public struct SchemaRuleRunner  : Sendable{
    public var rules: [SchemaRule]
    public var  ctx : ValidationContext 
    public init(rules: [SchemaRule], ctx: ValidationContext) {
        self.rules = rules
        self.ctx = ctx
    }
  
    public func run(schema: OpenAPISchema, pointer: String) -> [Diagnostic] {
        var out: [Diagnostic] = []
        

        // Recurse into schemaType (if no $ref on wrapper)
        if schema.ref == nil, let t = schema.schemaType {
            out.append(contentsOf: run(schemaType: t, pointer: pointer))
            
        }
        return out
    }
    public static func defaultRunner(ctx: ValidationContext) -> SchemaRuleRunner  {
        var rules : [SchemaRule] = [
            StringMinMaxLengthRule(),
            RequiredSubsetOfPropertiesRule()

        ]
        if ctx.dialect == .oas30 || ctx.version == .v30 {
            rules.append(OAS30SupportedTypesRule())
        }
        return SchemaRuleRunner(rules: rules, ctx: ctx)
    }
    private func run(schemaType: any OpenAPIValidatableSchemaType, pointer: String) -> [Diagnostic] {
        var out: [Diagnostic] = []
        out.append(contentsOf: rules.flatMap { $0.check(schemaType: schemaType, pointer: pointer) })
        if let obj = schemaType as? OpenAPIObjectType {
            for prop in obj.properties {
                if let key = prop.key,
                   let schemaType = prop.schemaOrSelf{
                    let p = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                    out.append(contentsOf: run(schemaType: schemaType , pointer: p))
                }
                
            }
        }

        if let arr = schemaType as? OpenAPIArrayType, let items = arr.items {
            out.append(contentsOf: run(schemaType: items, pointer: JSONPointer.join(pointer, "items")))
        }

        if let anyOf = schemaType as? OpenAPIAnyOfType, let items = anyOf.items {
            for (idx, item) in items.enumerated() {
                out.append(contentsOf: run(schemaType: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "anyOf"), "\(idx)")))
            }
        }

        if let oneOf = schemaType as? OpenAPIOneOfType, let items = oneOf.items {
            for (idx, item) in items.enumerated() {
                out.append(contentsOf: run(schemaType: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "oneOf"), "\(idx)")))
            }
        }

        if let allOf = schemaType as? OpenAPIAllOfType, let items = allOf.items {
            for (idx, item) in items.enumerated() {
                out.append(contentsOf: run(schemaType: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "allOf"), "\(idx)")))
            }
        }
        
        
        return out
    }
}

/// Rule: anyOf/oneOf/allOf must contain at least one item.
public struct NonEmptyCompositionRule: SchemaRule {
    public let name = "Schema.NonEmptyComposition"
    public init() {}

    public func check(schemaType: any OpenAPIValidatableSchemaType, pointer: String) -> [Diagnostic] {
        
        var diags: [Diagnostic] = []

        if let anyOf = schemaType as? OpenAPIAnyOfType, (anyOf.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "anyOf must contain at least one schema.",
                pointer: JSONPointer.join(pointer, "anyOf"),
                rule: name
            ))
        }

        if let oneOf = schemaType  as? OpenAPIOneOfType, (oneOf.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "oneOf must contain at least one schema.",
                pointer: JSONPointer.join(pointer, "oneOf"),
                rule: name
            ))
        }

        if let allOf = schemaType  as? OpenAPIAllOfType, (allOf.items ?? []).isEmpty {
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

    public func check(schemaType: any OpenAPIValidatableSchemaType, pointer: String) -> [Diagnostic] {
        guard let t = schemaType as? OpenAPIStringType else { return [] }
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

public struct OAS30SupportedTypesRule: SchemaRule {
    public let name = "Schema.SupportedTypes"
    public init() {}

    public func check(schemaType: any OpenAPIValidatableSchemaType, pointer: String) -> [Diagnostic] {
        
        if let t = (schemaType as? OpenAPIUnknownType) {
            return [.init(severity: .error, code: .invalidType,
                          message: "unknown type \(t.type ?? "")",
                          pointer: "\(pointer)/\(t.type ?? "")",
                          rule: "Schema.SupportedTypes")]
        }
        else if schemaType is OpenAPINullType {
            return [.init(severity: .error, code: .invalidType,
                          message: "Null type not supported in OpenAPI 3.0 (switch to nullable)",
                          pointer: "\(pointer)",
                          rule: "Schema.SupportedTypes")]
        }
       return []
    }
}


/// Rule: for objects, every entry in required must exist as a property key.
public struct RequiredSubsetOfPropertiesRule: SchemaRule {
    public let name = "Schema.RequiredSubsetOfProperties"
    public init() {}

    public func check(schemaType: any OpenAPIValidatableSchemaType, pointer: String) -> [Diagnostic] {
        guard let obj = schemaType as? OpenAPIObjectType else { return [] }
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

