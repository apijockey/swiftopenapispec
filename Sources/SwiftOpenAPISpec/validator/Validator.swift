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


public struct Validator {
   
    public enum Errors : LocalizedError {
        case invalidPointer(String), maxRecursion(String,Int), resolveError(String)
    }
    public static func validate(spec: OpenAPISpecification, baseURI: String, ctx: ValidationContext, resolver:  inout  JSONPointerResolver) async throws -> [Diagnostic] {
        let runner = RuleRunner.defaultRuleRunner
        return runner.run(spec: spec, ctx: ctx)
    }
    
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
            for schema in schemas {
                try await diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/components/schema", resolver: &resolver))
            }
        }
        // Validate requestBody content schemas in paths
        for path in spec.paths{
            for op in path.operations {
                for content in (op.requestBody?.contents ?? []) {
                    if let schema = content.schema  {
                        try await diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/paths/\(path.key ?? "")/\(op.key ?? op.operationId ?? "")/requestBody/content/\(content.key ?? "")", resolver: &resolver))
                    }
                    
                }
                for response in (op.responses ?? []) {
                    for content in response.content {
                        if let schema = content.schema  {
                            try await diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/paths/\(path.key ?? "")/operations/responses/\(response.key ?? "")/content/\(content.key ?? "")", resolver: &resolver))
                        }
                    }
                }
            }
        }
        return diagnostics
    }
}
