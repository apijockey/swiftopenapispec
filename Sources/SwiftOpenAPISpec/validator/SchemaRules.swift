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
    /// JSON Schema Draft 06 (Wright) runner - compatible with OpenAPI 3.0
    public static func wrightJSONSchemaRunner(ctx: ValidationContext) -> SchemaRuleRunner  {
        var rules = [SchemaRule]()
        
        // Common rules for all dialects
        rules.append(StringMinMaxLengthRule())
        rules.append(StringNumberMinimumMaximumhRule())
        rules.append(MultipleOfRule())
        rules.append(SchemaObjectReadOrWriteOnlyRule())
       
        rules.append(OneAnyAllMustHaveObjectArrayCompositionRule())
        rules.append(ArrayMinItemsRule())
        rules.append(ArrayMaxItemsRule())
        rules.append(ArrayMinMaxItemsRule())
        rules.append(ObjectMinPropertiesRule())
        rules.append(ObjectMaxPropertiesRule())
        rules.append(ObjectMinMaxPropertiesRule())
        
        rules.append(ObjectDependenciesRule())
        
        
        if ctx.dialect == .oas30 {
            rules.append(SupportedOAS30FormatsRule())
            rules.append(OAS30SupportedTypeRule())
            rules.append(OAS30SupportedRegexRule())
            rules.append(RequiredSubsetOfPropertiesV30Rule())
        }
        // OAS 3.1+ specific rules
        else {
            rules.append(OAS31SupportedTypeRule())
            rules.append(OAS30SupportedRegexRule())
            rules.append(RequiredSubsetOfPropertiesV31Rule())
        }
        
        return SchemaRuleRunner(rules: rules, ctx: ctx)
    }
    
    /// JSON Schema Draft 2020-12 (Bhutton) runner - includes modern JSON Schema features
    public static func bhuttonJSONSchemaRunner(ctx: ValidationContext) -> SchemaRuleRunner  {
        var rules = [SchemaRule]()
        
        // Start with Wright rules as base
        rules.append(contentsOf: wrightJSONSchemaRunner(ctx: ctx).rules)
        
        // Add JSON Schema 2020-12 specific rules
        rules.append(ArrayContainsRule())
       
        rules.append(DependentRequiredRule())
        rules.append(ContentEncodingRule())
        rules.append(ContentMediaTypeRule())
        rules.append(PrefixItemsRule())
        rules.append(PropertyNamesRule())
        rules.append(ObjectPatternPropertiesV31Rule())
        return SchemaRuleRunner(rules: rules, ctx: ctx)
    }
    
    /// Default runner - uses Wright for OAS 3.0, Bhutton for OAS 3.1+
    public static func defaultRunner(ctx: ValidationContext) -> SchemaRuleRunner  {
        if ctx.dialect == .oas30 {
            return wrightJSONSchemaRunner(ctx: ctx)
        } else {
            return bhuttonJSONSchemaRunner(ctx: ctx)
        }
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
                    if let properties = obj.additionalProperties,
                       case let .schema(array) = properties {
                        for prop in array {
                              if let key = prop.key{
                                  let p = JSONPointer.join(JSONPointer.join(pointer, "additionalProperties"), key)
                                  try await out.append(contentsOf: run(schema: prop , pointer: p,resolver: &resolver))
                              }
  
                          }
                    }
                    if let properties = obj.unevaluatedProperties,
                       case let .schema(array) = properties {
                        for prop in array {
                              if let key = prop.key{
                                  let p = JSONPointer.join(JSONPointer.join(pointer, "additionalProperties"), key)
                                  try await out.append(contentsOf: run(schema: prop , pointer: p,resolver: &resolver))
                              }
  
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
                        try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "anyOf"), "\(idx)"),resolver: &resolver))
                    }
                    
                }
                
            if case let .oneOf(openAPIAnyOfType) = type ,
               let items = openAPIAnyOfType.items {
                    for (idx, item) in items.enumerated() {
                        try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "oneOf"), "\(idx)"),resolver: &resolver))
                    }
                    
                }
                
            if case let .allOf(openAPIAnyOfType) = type,
               let items = openAPIAnyOfType.items {
                    for (idx, item) in items.enumerated() {
                        try await out.append(contentsOf: run(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "allOf"), "\(idx)"),resolver: &resolver))
                    }
                    
                }
                
                
            
            if case  .ref = type {
               return out
            }
            return out
        }
       return []
    }
   
// OLD DEFAULT RUNNER - REPLACED
// See new wrightJSONSchemaRunner and bhuttonJSONSchemaRunner below
}


/// Rule: anyOf/oneOf/allOf must contain at least one item.
public struct OneAnyAllMustHaveObjectArrayCompositionRule: SchemaRule {
    
    
    public let name = "Schema.OneAnyAllMustHaveObjectArray"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        
        var diags: [Diagnostic] = []
        
        if case let .anyOf(ofType) = schema.type,
            (ofType.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "'AnyOf' elements must be of type 'object'.",
                pointer: JSONPointer.join(pointer, "anyOf"),
                rule: name
            ))
        }
        
        if case let .oneOf(ofType) = schema.type,
            (ofType.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "'OneOf' elements must be of type 'object'.",
                pointer: JSONPointer.join(pointer, "oneOf"),
                rule: name
            ))
        }
        
        if case let .allOf(ofType) = schema.type,
           (ofType.items ?? []).isEmpty {
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "'AllOf' elements must be of type 'object'.",
                pointer: JSONPointer.join(pointer, "allOf"),
                rule: name
            ))
        }
        if case let .anyOf(ofType) = schema.type {
            for item in ofType.items  ?? [] {
                if case .object =  item.type { }
                else {
                    diags.append(.init(
                        severity: .error,
                        code: .schemaViolation,
                        message: "'AnyOf' elements must be of type 'object'.",
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
                        message: "'OneOf' elements must be of type 'object'.",
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
                        message: "'AllOf' elements must be of type 'object'.",
                        pointer: JSONPointer.join(pointer, "allOf"),
                        rule: name
                    ))
                }
            }
        }
        
        return diags
    }
}

/// Rule: Validate minContains and maxContains constraints for arrays
public struct ArrayContainsRule: SchemaRule {
    public let name = "Schema.ArrayContains"
    public init() {}

    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        
        guard case .array = schema.type else {
            return []
        }
        
        // Validate minContains
        if let minContains = schema.minContains {
            if minContains < 0 {
                diagnostics.append(.init(
                    severity: .error,
                    code: .schemaViolation,
                    message: "minContains must be 0 or higher, is \(minContains)",
                    pointer: JSONPointer.join(pointer, "minContains"),
                    rule: name
                ))
            }
        }
        
        // Validate maxContains
        if let maxContains = schema.maxContains {
            if maxContains < 0 {
                diagnostics.append(.init(
                    severity: .error,
                    code: .schemaViolation,
                    message: "maxContains must be 0 or higher, is \(maxContains)",
                    pointer: JSONPointer.join(pointer, "maxContains"),
                    rule: name
                ))
            }
        }
        
        // Validate minContains <= maxContains when both are present
        if let minContains = schema.minContains,
           let maxContains = schema.maxContains {
            if minContains > maxContains {
                diagnostics.append(.init(
                    severity: .error,
                    code: .schemaViolation,
                    message: "minContains \(minContains) must be <= maxContains \(maxContains)",
                    pointer: JSONPointer.join(pointer, "maxContains"),
                    rule: name
                ))
            }
        }
        
        return diagnostics
    }
}



/// Rule: Validate dependentRequired constraint
public struct DependentRequiredRule: SchemaRule {
    public let name = "Schema.DependentRequired"
    public init() {}

    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        
        guard case .object(let objectType) = schema.type else {
            return []
        }
        
        if let dependentRequired = objectType.dependentRequired {
            // dependentRequired should be a property name
            if dependentRequired.isEmpty {
                diagnostics.append(.init(
                    severity: .error,
                    code: .schemaViolation,
                    message: "dependentRequired must not be empty",
                    pointer: JSONPointer.join(pointer, "dependentRequired"),
                    rule: name
                ))
            }
            
            // Check if the dependent property exists in the schema
            let propertyKeys = Set(objectType.properties.map { $0.key })
            if !propertyKeys.contains(dependentRequired) {
                diagnostics.append(.init(
                    severity: .error,
                    code: .schemaViolation,
                    message: "dependentRequired property '\(dependentRequired)' does not exist in schema",
                    pointer: JSONPointer.join(pointer, "dependentRequired"),
                    rule: name
                ))
            }
        }
        
        return diagnostics
    }
}

/// Rule: Validate contentEncoding constraint
public struct ContentEncodingRule: SchemaRule {
    public let name = "Schema.ContentEncoding"
    public init() {}

    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        // contentEncoding is typically validated at the schema level
        // For now, we'll implement basic validation
        
        // Check if contentEncoding is a valid encoding (base64, etc.)
        // This would need to be extended with actual encoding validation
        return []
    }
}

/// Rule: Validate contentMediaType constraint
public struct ContentMediaTypeRule: SchemaRule {
    public let name = "Schema.ContentMediaType"
    public init() {}

    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        // contentMediaType validation would check for valid media types
        // This is a placeholder for future implementation
        return []
    }
}

/// Rule: Validate prefixItems constraint for arrays
public struct PrefixItemsRule: SchemaRule {
    public let name = "Schema.PrefixItems"
    public init() {}

    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case .array = schema.type else {
            return []
        }
        
        // prefixItems would be validated here
        // This is a placeholder for the actual implementation
        // In JSON Schema 2020-12, prefixItems replaces the items array behavior
        
        return []
    }
}

/// Rule: Validate propertyNames constraint for objects
public struct PropertyNamesRule: SchemaRule {
    public let name = "Schema.PropertyNames"
    public init() {}

    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case .object = schema.type else {
            return []
        }
        
        // propertyNames would be validated here
        // This constraint allows validation of property names against a schema
        
        return []
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
                code: .schemaViolation,
                message: "minLength '\(min)' must be <= maxLength '\(max)'.",
                pointer: JSONPointer.join(pointer, "maxLength"),
                rule: name
            )]
        }
        return []
    }
}


/// Rule: for strings, minLength <= maxLength (when both present).
public struct ArrayMinItemsRule: SchemaRule {
    public let name = "Schema.ArrayMinItems"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case  .array = schema.type,
              let minItems = schema.minItems else { return [] }
        if minItems < 0 {
            return [.init(severity: .error, code: .schemaViolation, 
                          message: "minItems must be 0 or higher, is \(minItems)",
                          pointer: JSONPointer.join(pointer, "minItems"), rule: self.name)]
        }
        return []
    }
}


/// Rule: for strings, minLength <= maxLength (when both present).
public struct ArrayMaxItemsRule: SchemaRule {
    public let name = "Schema.ArrayMaxItems"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case  .array = schema.type,
              let maxItems = schema.maxItems else { return [] }
        if maxItems < 0 {
            return [.init(severity: .error, code: .schemaViolation,
                          message: "maxItems must be 0 or higher, is \(maxItems)",
                          pointer: JSONPointer.join(pointer, "maxItems"), rule: self.name)]
        }
        return []
    }
}

/// Rule: for strings, minLength <= maxLength (when both present).
public struct ArrayMinMaxItemsRule: SchemaRule {
    public let name = "Schema.ArrayMinMaxItems"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case  .array = schema.type,
              let minItems = schema.minItems,
              let maxItems = schema.maxItems else { return [] }
        if minItems > maxItems{
            return [.init(severity: .error, code: .schemaViolation,
                          message: "minItems \(minItems) must <= maxItems '\(maxItems)'",
                          pointer: JSONPointer.join(pointer, "maxItems"), rule: self.name)]
        }
        return []
    }
}

/// Rule: for strings, minLength <= maxLength (when both present).
public struct ObjectMinPropertiesRule: SchemaRule {
    public let name = "Schema.ObjectMinProperties"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case  .object = schema.type,
              let minProperties = schema.minProperties else { return [] }
        if minProperties < 0 {
            return [.init(severity: .error, code: .schemaViolation,
                          message: "minProperties must be 0 or higher, is \(minProperties)",
                          pointer: JSONPointer.join(pointer, "minProperties"), rule: self.name)]
        }
        return []
    }
}


/// Rule: for strings, minLength <= maxLength (when both present).
public struct ObjectMaxPropertiesRule: SchemaRule {
    public let name = "Schema.ObjectMaxProperties"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case  .object = schema.type,
              let maxProperties = schema.maxProperties else { return [] }
        if maxProperties < 0 {
            return [.init(severity: .error, code: .schemaViolation,
                          message: "maxProperties must be 0 or higher, is \( maxProperties)",
                          pointer: JSONPointer.join(pointer, "maxProperties"), rule: self.name)]
        }
        return []
    }
}

/// Object properties names must follow patternProperties regex if set
public struct ObjectPatternPropertiesV31Rule: SchemaRule {
    public let name = "Schema.ObjectPatternProperties"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        guard case  .object(let objectElement) = schema.type else {
            return []
        }
        if let pattern = objectElement.patternProperties {
            if !pattern.isValidRegex() {
                    diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "Pattern properties must be a valid regular expression", pointer: JSONPointer.join(pointer,"patternProperties"), rule: self.name))
            }
                
            
        }
        
            
        return diagnostics
    }
}

/// Object properties names must follow patternProperties regex if set
public struct OneAnyAllofItemsRule: SchemaRule {
    public let name = "Schema.OneAnyAllofItems"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        if case  .anyOf(let objectElement) = schema.type,
           objectElement.items?.count == 0 {
            diagnostics.append(Diagnostic(severity: .error,
                                           code: .schemaViolation,
                                           message: "anyOf' must contain an array of 'object'.",
                                           pointer: JSONPointer.join(pointer, "type"), rule: "Schema.OneAnyAllofItems"))
        }
        if case  .allOf(let objectElement) = schema.type,
           objectElement.items?.count == 0 {
            diagnostics.append(Diagnostic(severity: .error,
                                           code: .schemaViolation,
                                           message: "allOf' must contain an array of 'object'.",
                                           pointer: JSONPointer.join(pointer, "type"), rule: "Schema.OneAnyAllofItems"))
        }
        if case  .oneOf(let objectElement) = schema.type,
           objectElement.items?.count == 0 {
            diagnostics.append(Diagnostic(severity: .error,
                                           code: .schemaViolation,
                                           message: "oneOf' must contain an array of 'object'.",
                                           pointer: JSONPointer.join(pointer, "type"), rule: "Schema.OneAnyAllofItems"))
        }
            return diagnostics
    }
}



/// Rule: for strings, minLength <= maxLength (when both present).
public struct ObjectDependenciesRule: SchemaRule {
    public let name = "Schema.ObjectDependencies"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        guard case  .object(let objectElement) = schema.type else {
            return []
        }
        let dependencies = objectElement.dependencies
        for (key, value) in (dependencies ?? [:]){
            if case .array(let array) = value {
                if array.isEmpty {
                    diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency array must have at least one element", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"), key), rule: self.name))
                }
                var uniqueElements = Set<String>()
                for (index,element) in array.enumerated() {
                    if case .string(let string) = element {
                        if uniqueElements.contains(string) {
                            diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency array elements must be unique", pointer: JSONPointer.join(JSONPointer.join(JSONPointer.join(pointer,"dependencies"), key),String(index)), rule: self.name))
                            return diagnostics
                        }
                        else {
                            uniqueElements.insert(string)
                        }
                    }
                    else {
                        diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency array elements must be strings", pointer: JSONPointer.join(JSONPointer.join(JSONPointer.join(pointer,"dependencies"), key),String(index)), rule: self.name))
                    }
                    
                }
                return diagnostics
            }
            else if case .object(let dictionary) = value {
                if dictionary.isEmpty {
                    diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "Object dependencies must map to a non-empty array", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"), key), rule: self.name))
                    return diagnostics
                }
                
                
            }
            else if case .boolean = value {
                diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency value must be an object or array, not boolean", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"),key), rule: self.name))
                    
            }
            else if case .integer = value {
                diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency value must be an object or array, not integer", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"),key), rule: self.name))
            }
            else if case .number = value {
                diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency value must be an object or array, not number", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"),key), rule: self.name))
            }
            else if case .string = value {
                diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency value must be an object or array, not string", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"),key), rule: self.name))
            }
            else if case .null = value {
                diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency value must be an object or array, not null", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"),key), rule: self.name))
            }
            else {
                diagnostics.append(.init(severity: .error, code: .schemaViolation, message: "dependency value must be an object or array, is undefined", pointer: JSONPointer.join(JSONPointer.join(pointer,"dependencies"),key), rule: self.name))
            }
            
            }
        return diagnostics

    }
}

/// Rule: for strings, minLength <= maxLength (when both present).
public struct ObjectMinMaxPropertiesRule: SchemaRule {
    public let name = "Schema.ObjectMinMaxProperties"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard case  .object = schema.type,
              let minProperties = schema.minProperties,
              let maxProperties = schema.maxProperties else { return [] }
        if minProperties > maxProperties{
            return [.init(severity: .error, code: .schemaViolation,
                          message: "minProperties \(minProperties) must <= maxProperties '\( maxProperties)'",
                          pointer: JSONPointer.join(pointer, "maxProperties"), rule: self.name)]
        }
        return []
    }
}




/// Rule: for strings, minLength <= maxLength (when both present).
public struct StringNumberMinimumMaximumhRule: SchemaRule {
    public let name = "Schema.NumberMinimumMaximum"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
       
        
        guard let min = schema.minimum,
            let max = schema.maximum else { return [] }
        if case .integer = schema.type,
           Int(min) > Int(max) {
            return [.init(
                severity: .error,
                code: .schemaViolation,
                message: "minimum '\(Int(min))' must be <= maximum '\(Int(max))'.",
                pointer: JSONPointer.join(pointer, "maximum"),
                rule: name
            )]
        }
        else if case .number = schema.type {
            return [.init(
                severity: .error,
                code: .schemaViolation,
                message: "mininum '\(min)' must be <= maximum '\(max)'.",
                pointer: JSONPointer.join(pointer, "maximum"),
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
            code: .schemaViolation,
            message: "The value of 'multipleOf' MUST be strictly greater than 0",
            pointer: JSONPointer.join(pointer,"multipleOf"),
            rule: name
        )]
    }
}

public struct SchemaObjectReadOrWriteOnlyRule: SchemaRule {
    public let name = "Schema.ReadOrWriteOnly"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        if schema.readOnly == true && schema.writeOnly == true {
            return [.init(
                severity: .error,
                code: .schemaViolation,
                message: "A property MUST NOT be marked as both 'readOnly' and 'writeOnly' being 'true'. ",
                pointer: JSONPointer.join(pointer,"readonly"),
                rule: name
            )]
        }
        else {
            return []
        }
        
    }
}

public struct OAS30SupportedRegexRule: SchemaRule {
    public let name = "Schema.SupportedRegex"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        guard let regex = schema.pattern else {
            return []
        }
        if regex.isValidRegex() {
            return []
        }
        else {
            return [.init(severity: .error, code: .invalidValue,
                         message: "'\(regex) is not a supportedRegex",
                         pointer: "\(pointer)/type",
                         rule: self.name)]
        }
        
    }
}

public struct OAS30SupportedTypeRule: SchemaRule {
    public let name = "OAS30.SupportedTypes"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        
        
        if case .null = schema.type {
            return [.init(severity: .error, code: .invalidType,
                          message: "'null' type not supported in OpenAPI 3.0 (switch to nullable)",
                          pointer: "\(pointer)/type",
                          rule: self.name)]
        }
        else if case .unknown(let type) = schema.type {
            return [.init(severity: .error, code: .schemaViolation,
                          message: "type '\(type)' not supported or not recognized in OpenAPI 3.0",
                          pointer: "\(pointer)/type",
                          rule: self.name)]
        }
        return []
    }
}

public struct OAS31SupportedTypeRule: SchemaRule {
    public let name = "OAS31.SupportedTypes"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        
        
       if case .unknown(let type) = schema.type {
            return [.init(severity: .error, code: .schemaViolation,
                          message: "type '\(type)' not supported or not recognized in OpenAPI 3.1",
                          pointer: "\(pointer)/type",
                          rule: self.name)]
        }
        return []
    }
}


/// Rule: for objects, every entry in required must exist as a property key.
public struct RequiredSubsetOfPropertiesV31Rule: SchemaRule {
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
public struct RequiredSubsetOfPropertiesV30Rule: SchemaRule {
    public let name = "Schema.RequiredSubsetOfProperties"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        guard case let .object(openAPIObjectType) = schema.type else {
            return []
        }
        let required = openAPIObjectType.required
        if required.isEmpty {
            
            diags.append(.init(
                severity: .error,
                code: .schemaViolation,
                message: "required elements must not be empty",
                pointer: JSONPointer.join(pointer, "required"),
                rule: name
            ))
            
        }
        
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
public struct SupportedOAS30FormatsRule: SchemaRule {
    public let name = "Schema.SupportedFormat"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        
        if case .string = schema.type {
            if ["byte","binary", "date","date-time", "email","hostname", "password", "ipv4", "ipv6", "uri", "uriref"].contains(schema.format)  || schema.format == nil { return [] }
            else {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not predefined for 'string'", pointer: JSONPointer.join(pointer, "format"), rule: name))
            }
        }
        else if case .integer = schema.type {
            if  ["int32","int64"].contains(schema.format) || (schema.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not predefined for 'integer'", pointer:  JSONPointer.join(pointer, "format"), rule: name))
            }
        }
            
        else if case  .number = schema.type {
        if  ["float","double"].contains(schema.format) || (schema.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not predefined for 'number'", pointer:  JSONPointer.join(pointer, "format"), rule: name))
            }
        }
        else {
            if !(schema.format ?? "").isEmpty {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not expected", pointer:  JSONPointer.join(pointer, "format"), rule: name))
            }
        }
        
        return diags
    }
}
//TODO: JSONSchema
/// Rule: for objects, every entry in required must exist as a property key.
public struct SupportedOAS31FormatsRule: SchemaRule {
    public let name = "Schema.SupportedFormat"
    public init() {}
    
    public func check(schema: OpenAPISchema, ctx: ValidationContext, pointer: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        
        if case .string = schema.type {
            if ["byte","binary","", "date","date-time ","password"].contains(schema.format)  || schema.format == nil { return [] }
            else {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not predefined for 'string'", pointer: JSONPointer.join(pointer, "format"), rule: name))
            }
        }
        else if case .integer = schema.type {
            if  ["int32","int64"].contains(schema.format) || (schema.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not predefined for 'integer'", pointer:  JSONPointer.join(pointer, "format"), rule: name))
            }
        }
        
        else if case  .number = schema.type {
            if  ["float","double"].contains(schema.format) || (schema.format ?? "").isEmpty {
                return []
            }
            else {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not predefined for 'number'", pointer:  JSONPointer.join(pointer, "format"), rule: name))
            }
        }
        else {
            if !(schema.format ?? "").isEmpty {
                diags.append(Diagnostic(severity: .warning, code: .schemaViolation, message: "format '\(schema.format ?? "")' not expected", pointer:  JSONPointer.join(pointer, "format"), rule: name))
            }
        }
        
        return diags
    }
   
}
