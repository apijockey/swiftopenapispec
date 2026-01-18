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
   
    public static func validate(spec: OpenAPISpecification, baseURI: String, ctx: ValidationContext, resolver:  inout  JSONPointerResolver) async throws -> [Diagnostic] {
        let runner = RuleRunner.defaultRuleRunner
        return runner.run(spec: spec, ctx: ctx)
    }
    public static func validateRefs(spec: OpenAPISpecification, baseURI: String, ctx: ValidationContext, resolver:  inout  JSONPointerResolver) async throws -> [Diagnostic] {
        var occurrences = [RefOccurrence]()
        for (schema) in (spec.components?.schemas ?? []){
            let p = "/components/schemas/\(JSONPointer.escape(schema.key ?? ""))"
            occurrences += SchemaRefCollector().collect(from: schema, pointer: p)
        }
        for path in spec.paths {
            for op in path.operations {
                if let reqBody = op.requestBody {
                    let path = "/paths/\(JSONPointer.escape(path.key ?? ""))/operations/\(op.key ?? "")" + "/requestBody"
                    for content in (reqBody.contents) {
                        occurrences += SchemaRefCollector().collect(from: content, pointer: path)
                        
                    }
                }
                if let response = op.responses {
                    for response in response {
                            let path = "/paths/\(JSONPointer.escape(path.key ?? ""))/operations/\(op.key ?? "")" + "/responses/\(response.key ?? "")"
                            occurrences += SchemaRefCollector().collect(from: response, pointer: path)
                    }
                }
            }
        }
        let diags = await ResolveRefsRule().check(refs: occurrences, resolver: &resolver)
        return diags
    }
    public static func validateSchema(spec: OpenAPISpecification, ctx: ValidationContext,baseURI: String, resolver:  inout  JSONPointerResolver) async throws -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
       
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
                        try await diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/paths/schema/requestBody/content/\(content.key ?? "")", resolver: &resolver))
                    }
                    
                }
                for response in (op.responses ?? []) {
                    for content in response.content {
                        if let schema = content.schema  {
                            try await diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/paths/schema/responses/\(response.key ?? "")/content/\(content.key ?? "")", resolver: &resolver))
                        }
                    }
                }
            }
        }
       
        return diagnostics
    }
}
