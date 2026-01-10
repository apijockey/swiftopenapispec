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
   
    public static func validate(spec: OpenAPISpecification, baseURI: String, ctx: ValidationContext) -> [Diagnostic] {
        let runner = RuleRunner.defaultRuleRunner
        return runner.run(spec: spec, ctx: ctx)
    }
    public static func validateSchema(spec: OpenAPISpecification, ctx: ValidationContext,baseURI: String) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
       
        let schemaRuleRunner = SchemaRuleRunner.defaultRunner(ctx: ctx)
        if let schemas = spec.components?.schemas {
            for schema in schemas {
                diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/components/schema"))
            }
        }
        // Validate requestBody content schemas in paths
        spec.paths.forEach { path in
            path.operations.forEach { op in
                (op.requestBody?.contents ?? []).forEach { content in
                    if let schema = content.schema  {
                        diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/paths/schema/requestBody/content/\(content.key ?? "")"))
                    }
                    
                }
                (op.responses ?? []).forEach( { response in
                    response.content.forEach { content in
                        if let schema = content.schema  {
                            diagnostics.append(contentsOf:schemaRuleRunner.run(schema: schema, pointer: "/paths/schema/responses/\(response.key ?? "")/content/\(content.key ?? "")"))
                        }
                    }
                })
            }
        }
       
        return diagnostics
    }
}
