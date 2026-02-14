/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
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
//  Created by Patric Dubois on 01.01.26.
//

import Foundation



/// A validator for OpenAPI specifications that checks for compliance with the OpenAPI standard.
///
/// The `Validator` struct provides functionality to validate OpenAPI specifications against
/// the OpenAPI standard and detect issues such as:
/// - Structural problems
/// - Schema validation errors
/// - Reference resolution issues
/// - Rule violations
///
/// Validation helps ensure that OpenAPI specifications are well-formed and can be reliably
/// used for code generation, documentation, and other purposes.
///
/// ## Features
///
/// - **Rule-based Validation**: Applies a comprehensive set of validation rules
/// - **Schema Validation**: Validates schemas against JSON Schema standards
/// - **Reference Resolution**: Checks that all references can be resolved
/// - **Diagnostic Reporting**: Provides detailed error and warning messages
///
/// ## Example Usage
///
/// ```swift
/// let spec = try OpenAPISpecification.read(text: yamlText)
/// var resolver = JSONPointerResolver()
/// let ctx = ValidationContext()
/// 
/// do {
///     let diagnostics = try await Validator.validate(
///         spec: spec,
///         baseURI: "https://example.com/api",
///         ctx: ctx,
///         resolver: &resolver
///     )
///     
///     if diagnostics.isEmpty {
///         print("Specification is valid!")
///     } else {
///         for diagnostic in diagnostics {
///             print("Issue: \(diagnostic.message) at \(diagnostic.pointer)")
///         }
///     }
/// } catch {
///     print("Validation error: \(error)")
/// }
/// ```
public struct Validator {
   
    /// Errors that can occur during validation.
    ///
    /// - `invalidPointer`: The JSON pointer is invalid or cannot be parsed
    /// - `maxRecursion`: Maximum recursion depth exceeded while resolving references
    /// - `resolveError`: Error occurred while resolving a reference

    public enum Errors : LocalizedError {
        /// Invalid JSON pointer syntax or usage.
        /// - Parameter: The invalid pointer string
        case invalidPointer(String)
        
        /// Maximum recursion depth exceeded during reference resolution.
        /// - Parameters:
        ///   - pointer: The pointer that caused the recursion
        ///   - depth: The maximum depth that was exceeded
        case maxRecursion(String,Int)
        
        /// General resolution error during reference processing.
        /// - Parameter: Description of the resolution error
        case resolveError(String)
    }

    /// Validates an OpenAPI specification against the OpenAPI standard.
    ///
    /// This method performs comprehensive validation of the OpenAPI specification, including:
    /// - Applying all validation rules from the rule runner
    /// - Checking schema-related diagnostics
    /// - Resolving and validating references
    ///
    /// - Parameters:
    ///   - spec: The OpenAPI specification to validate
    ///   - baseURI: The base URI for resolving relative references
    ///   - ctx: The validation context containing configuration and state
    ///   - resolver: The JSON pointer resolver for resolving references
    /// - Returns: An array of diagnostics (errors and warnings) found during validation
    /// - Throws: `Errors` if critical validation errors occur
    ///
    /// ## Validation Process
    ///
    /// 1. Runs all validation rules using the default rule runner
    /// 2. Collects schema-specific diagnostics from the specification
    /// 3. Returns combined diagnostics for analysis
    ///
    /// Empty diagnostics array indicates a valid specification.


    public static func validate(spec: OpenAPISpecification, baseURI: String, ctx: ValidationContext, resolver:  inout  JSONPointerResolver) async throws -> [Diagnostic] {
        let runner = RuleRunner(version: ctx.version)
        var diagnostics = runner.run(spec: spec, ctx: ctx)
        let schemaDiagnostics: [Diagnostic] = spec.diagnostics.filter { diagnostic in
            diagnostic.rule.starts(with: "OAS")
        }
        diagnostics.append(contentsOf: schemaDiagnostics)
        return diagnostics
    }
    
    /// Finds all reference occurrences in an OpenAPI specification.

    ///
    /// This method scans the specification for references to reusable components and returns
    /// information about where each reference is used. This is useful for:
    /// - Understanding component usage
    /// - Detecting circular references
    /// - Analyzing specification structure
    ///
    /// - Parameters:
    ///   - spec: The OpenAPI specification to analyze
    ///   - baseURI: The base URI for resolving relative references
    ///   - ctx: The validation context (currently unused in this method)
    ///   - resolver: The JSON pointer resolver (currently unused in this method)
    /// - Returns: An array of `RefOccurrence` objects describing where references are used
    ///
    /// ## Scanned Components
    ///
    /// The method scans these component types for references:
    /// - Schemas in the components/schemas section
    /// - Request bodies in the components/requestBodies section
    /// - Responses in the components/responses section
    ///
    /// Each occurrence includes the JSON pointer to the component and information about
    /// the references found within it.

    public static func findOccurrences(spec: OpenAPISpecification, baseURI: String, ctx: ValidationContext, resolver:  inout  JSONPointerResolver) -> [RefOccurrence] {
        var occurrences = [RefOccurrence]()
        for (schema) in (spec.components?.schemas ?? []){
            let p = "/components/schemas/\(JSONPointer.escape(schema.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: schema, pointer: p)
        }
        for (requestBody) in (spec.components?.requestBodies ?? []){
            let p = "/components/requestBodies/\(JSONPointer.escape(requestBody.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: requestBody, pointer: p)
        }
        for (response) in (spec.components?.responses ?? []){
            let p = "/components/responses/\(JSONPointer.escape(response.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: response, pointer: p)
        }
        for (parameter) in (spec.components?.parameters ?? []){
            let p = "/components/parameters/\(JSONPointer.escape(parameter.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: parameter, pointer: p)
        }
        for (header) in (spec.components?.headers ?? []){
            let p = "/components/headers/\(JSONPointer.escape(header.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: header, pointer: p)
        }
        for (securityScheme) in (spec.components?.securitySchemas ?? []){
            let p = "/components/securitySchemes/\(JSONPointer.escape(securityScheme.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: securityScheme, pointer: p)
        }
        for (link) in (spec.components?.links ?? []){
            let p = "/components/links/\(JSONPointer.escape(link.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: link, pointer: p)
        }
        
        for path in spec.paths {
                let pointer = "/paths/\(JSONPointer.escape(path.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: path, pointer: pointer)
        }
        for encoding in (spec.components?.mediaTypes ?? []) {
            let pointer = "/components/encodings/\(JSONPointer.escape(encoding.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: encoding, pointer: pointer)
        }
        for (callback) in (spec.components?.callbacks ?? []){
            let p = "/components/callbacks"
            
            let subPath = "/\(JSONPointer.escape(callback.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: callback, pointer: p + subPath)
        }
        for example in (spec.components?.examples ?? []) {
                let pointer = "/components/examples/\(JSONPointer.escape(example.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: example, pointer: pointer)
        }
      
        return occurrences
    }
    public static func validateRefs(spec: OpenAPISpecification, baseURI: String, ctx: ValidationContext, resolver:  inout  JSONPointerResolver) async throws -> [Diagnostic] {
       let occurrences = findOccurrences(spec: spec, baseURI: baseURI, ctx: ctx, resolver: &resolver)
       
        let diags = await ResolveRefsRule().check(refs: occurrences, resolver: &resolver)
        return diags
    }
    public static func validateSchema(spec: OpenAPISpecification, ctx: ValidationContext,baseURI: String, resolver:  inout  JSONPointerResolver) async throws -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        let  diags = try await validateRefs(spec: spec, baseURI: baseURI, ctx: ctx, resolver: &resolver)
        if diags.count > 0 {
            return diags
        }
        let schemaRuleRunner = SchemaRuleRunner.defaultRunner(ctx: ctx)
        if let schemas = spec.components?.schemas {
            for namedSchema in schemas {
                try await diagnostics.append(contentsOf:schemaRuleRunner.run(schema: namedSchema, pointer: "/components/schemas/\(namedSchema.key ?? "")", resolver: &resolver))
                
            }
        }
        for info in RuleRunner.mediaTypes(spec: spec)  {
            let pointer = info.pointer
            let content = info.item
            if let schema = content.schema  {
                try await diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: JSONPointer.join(pointer, "/schema"), resolver: &resolver))
            }
            
        }
        diagnostics.append(contentsOf: spec.diagnostics.filter{$0.code == .schemaViolation})
        return diagnostics
    }
}
