//* Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
/*
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

import Foundation

struct SupportedVersion3: Rule {
    let name = "OAS.UnsupportedVersion3"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        guard  let version = spec.version,
               ["3.0.0","3.0.1","3.0.2","3.0.3","3.0.4", "3.1.0", "3.1.1","3.1.2", "3.2.0"].contains(version) else {
            return [.init(severity: .error,
                          code: .invalidValue,
                          message: "unsupported Version'\(spec.version ?? "") '",
                          pointer: "/openapi",
                          rule: name)]
        }
        return []
    }
}


struct OpenAPISpecificationV30FieldsNotAllowed:  Rule{
    let name = "OAS.OpenAPISpecificationV30FieldsNotAllowed"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
       var diagnostics: [Diagnostic] = []
        if spec.selfUrl != nil {
            let diag = Diagnostic(severity: .error,
                                  code: .invalidElement,
                                  message: "openapi.selfURL is not allowed in OpenAPI 3.0/3.1",
                                  pointer: "openapi/selfUrl",
                                  rule: name)
            diagnostics.append(diag)
        }
        if spec.jsonSchemaDialect != nil {
            let diag = Diagnostic(severity: .error,
                                  code: .invalidElement,
                                  message: "openapi.jsonSchemaDialect is not allowed in OpenAPI 3.0/3.1",
                                  pointer: "#/jsonSchemaDialect",
                                  rule: name)
            diagnostics.append(diag)
        }
        if spec.webhooks.count > 0{
            let diag = Diagnostic(severity: .error,
                                  code: .invalidElement,
                                  message: "openapi.webhooks is not allowed in OpenAPI 3.0/3.1",
                                  pointer: "#/webhooks",
                                  rule: name)
            diagnostics.append(diag)
        }
        return diagnostics
    }
}

struct OpenAPIInfoV30FieldsNotAllowed:  Rule{
    let name = "OAS.OpenAPISpecificationV30FieldsNotAllowed"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        if spec.info?.summary != nil {
            let diag = Diagnostic(severity: .error,
                                  code: .invalidElement,
                                  message: "info.summary is not allowed in OpenAPI 3.0",
                                  pointer: "#/info/summary",
                                  rule: name)
            diagnostics.append(diag)
        }
        return diagnostics
    }
}

struct RequiredOpenAPI30FixedFieldsRule: Rule {
    let name = "OAS.RequiredOpenAPIFixedFields"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        guard spec.info != nil,
              spec.version != nil,
              spec.paths.isEmpty == false else {
            return [.init(severity: .error,
                          code: .missingRequired,
                          message: "openapi, info, and paths are required",
                          pointer: "#/",
                          rule: name)]
        }
        return []
    }
}

struct RequiredOpenAPI31FixedFieldsRule: Rule {
    let name = "OAS.RequiredOpenAPIFixedFields"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        guard spec.info != nil,
              spec.version != nil,
              spec.paths.isEmpty == false && spec.webhooks.isEmpty &&   spec.components == nil else {
            return [.init(severity: .error,
                          code: .missingRequired,
                          message: "openapi, info, and paths or components or webhooks are required",
                          pointer: "#/",
                          rule: name)]
        }
        return []
    }
}



struct RequiredOpenAPIFixedInfoFieldsRule: Rule {
    let name = "OAS.RequiredOpenAPIFixedInfoFields"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        guard let info = spec.info,
              info.title != nil,
              let version = info.version,
              !version.isEmpty else {
            return [.init(severity: .error,
                          code: .missingRequired,
                          message: "info element requires 'title' and 'version'.",
                          pointer: "#/info",
                          rule: name)]
        }
        return []
    }
}

struct  OpenAPILicenseV30FieldsNotAllowed: Rule {
    let name = "OpenAPILicenseV30FieldsNotAllowed"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        if let license = spec.info?.license,
           license.identifier != nil  {
            diagnostics.append(.init(severity: .error,
                                     code: .invalidElement,
                                     message: "license.identifier is not allowed in OpenAPI 3.0/3.1",
                                     pointer: "#/info/license/identifier",
                                     rule: name))
            
        }
        return diagnostics
    }
}

struct RequiredLicenseNameRule: Rule {
    let name = "OAS.RequiredLicenseName"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        
        if let license = spec.info?.license,
           license.name == nil {
            return [.init(severity: .error,
                          code: .missingRequired,
                          message: "Missing license 'name'.",
                          pointer: "#/info/license/name",
                          rule: name)]
        }
        return []
    }
}

struct RequiredServerURLRule: Rule {
    let name = "OAS.ServerURL"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
       
        for server in spec.servers  {
            if server.url == nil {
                diagnostics.append( .init(severity: .error,
                              code: .missingRequired,
                              message: "Missing required field 'url' in one of the 'servers'.",
                              pointer: "#/servers/\(server.key ?? "")/url",
                              rule: name))
            }
        }
        return diagnostics
    }
    
    
}
struct  ValidComponentNamesRule: Rule {
    let name = "SupportedComponentNamesRule"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        for schema in (spec.components?.schemas ?? []) {
            if let key = schema.key {
                if !key.matches("^[a-zA-Z0-9\\.\\-_]+$") {
                    diagnostics.append(.init(severity: .error, code: .invalidValue, message: name, pointer: "/components/schemas/\(key)", rule: self.name))
                }
            }
        }
        return diagnostics
    }
}

struct  OpenAPIComponentV30FieldsNotAllowed: Rule {
    let name = "OpenAPIComponentV30FieldsNotAllowed"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        if let pathItems = spec.components?.pathItems,
           pathItems.count > 0 {
            diagnostics.append(.init(severity: .error, code: .invalidElement, message: "The 'components.pathItems' property is not supported in OpenAPI 3.0", pointer: "#/components/pathItems", rule: self.name))
        }
        return diagnostics
    }
}
struct  OpenAPIComponentV30_1FieldsNotAllowed: Rule {
    let name = "OpenAPIComponentV30FieldsNotAllowed"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        if let mediaTypes = spec.components?.mediaTypes,
           mediaTypes.count > 0 {
            diagnostics.append(.init(severity: .error, code: .invalidElement, message: "The 'components.mediaTypes' property is not supported in OpenAPI 3.0/3.1", pointer: "#/components/mediaTypes", rule: self.name))
        }
        return diagnostics
    }
}

struct  OpenAPIPathV30_ItemFieldsNotAllowed: Rule {
    let name = "OpenAPIPathV30_ItemFieldsNotAllowed:"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        for info in RuleRunner.pathItemInfo(spec: spec) {
            let pointer = info.pointer
            let pathItem = info.item
            if pathItem.additionalOperations.count > 0 {
                diagnostics.append(.init(severity: .error, code: .invalidElement, message: "Path items do not support 'additionalOperations' in OpenAPI 3.0/3.1 does not support HTTP methods as properties.", pointer: pointer, rule: self.name))
            }
        }
        return diagnostics
    }
}

struct  OpenAPIMediaTypeV30_1ItemFieldsNotAllowed: Rule {
    let name = "OpenAPIPathV30_ItemFieldsNotAllowed:"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics = [Diagnostic]()
        for info in RuleRunner.mediaTypes(spec: spec) {
            let pointer = info.pointer
            let mediaType = info.item
            if mediaType.encoding.count > 0  || mediaType.itemEncoding.count > 0 || mediaType.prefixEncoding.count > 0 {
                diagnostics.append(.init(severity: .error, code: .invalidElement, message: "MediaTypes do not support 'encoding', 'itemEncoding' or 'prefixEncoding' in OpenAPI 3.0/3.1.", pointer: pointer, rule: self.name))
                
            }
        }
        return diagnostics
    }
}

struct RequiredServerVariablesRule: Rule {
    let name = "OAS.ServerVariables"
    
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
       
        for server in spec.servers  {
            for variable in server.variables  {
                if variable.defaultValue == nil {
                    diagnostics.append(.init(severity: .error,
                                  code: .missingRequired,
                                  message: "Missing required field 'default' in one of the 'servers' variables.",
                                  pointer: "#/servers/\(server.key ?? "")/variables/\(variable.key ?? "")/default",
                                             rule: name))
                                       
                }
            }
        }
        return diagnostics
    }
}

//struct RequiredParameterSchemaOrContentPropertyRule: Rule {
//    let name = "OAS.RequiredParameterSchemaOrContentProperty"
//    
//    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
//        var diagnostics: [Diagnostic] = []
//        // falls spec.paths optional wäre – bei dir scheint es non-optional zu sein
//        let parameters = spec.paths.flatMap { path in
//            path.operations.flatMap { op in op.parameters ?? [] }
//
//        }
//        for parameter in parameters {
//            if parameter.schema == nil && parameter.content == nil && parameter.ref == nil {
//                
//            }
//        }
//        return diagnostics
//    }
//}


struct RequiredSchemaComponentNamessRule: Rule {
    let name = "OAS.ComponentSchemaName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        
        guard let schemas = spec.components?.schemas else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
                
                if !key.matches("[a-zA-Z0-9\\-\\._]+") {
                    diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\-\\._]+$'", pointer: "#/components/schema/\(key)", rule: name))
                }
            }
            
            
        }
        return diagnostics
    }
}

struct RequiredResponsesComponentNamessRule: Rule {
    let name = "OAS.ComponentResponsesName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        // falls spec.paths optional wäre – bei dir scheint es non-optional zu sein
        guard let schemas = spec.components?.responses else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
                if !key.matches("[a-zA-Z0-9\\.\\-_]+") {
                    diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\.\\-_]+$'", pointer: "#/components/responses/\(key)", rule: name))
                    
                }
                
            }
           
        }
        return diagnostics
    }
}

struct RequiredParameterComponentsNamessRule: Rule {
    let name = "OAS.ComponentParameterName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
      
        guard let schemas = spec.components?.parameters else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
                
                    if !key.matches("[a-zA-Z0-9\\.\\-_]+") {
                        diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\.\\-_]+$'", pointer: "#/components/parameters/\(key)", rule: name))
                    }
                
            }
            
        }
        return diagnostics
    }
}

struct RequiredExamplesComponentNamessRule: Rule {
    let name = "OAS.ComponentExampleName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
       
        guard let schemas = spec.components?.examples else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
                    if !key.matches("[a-zA-Z0-9\\.\\-_]+") {
                        diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\.\\-_]+$'", pointer: "#/components/examples/\(key)", rule: name))
                    }
              
            }
            
        }
        return diagnostics
    }
}

struct RequiredRequestBodiesComponentsNamessRule: Rule {
    let name = "OAS.ComponentRequestBodiesName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
       
        guard let schemas = spec.components?.requestBodies else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
                    if !key.matches("[a-zA-Z0-9\\.\\-_]+") {
                        diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\.\\-_]+$'", pointer: "#/components/requestBodies/\(key)", rule: name))
                    }
                
            }
            
        }
        return diagnostics
    }
}

struct RequiredsHeaderComponentsNamessRule: Rule {
    let name = "OAS.ComponentHeaderName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
       
        guard let schemas = spec.components?.headers else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
                    if !key.matches( "[a-zA-Z0-9\\.\\-_]+") {
                        diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\.\\-_]+$'", pointer: "#/components/headers/\(key)", rule: name))
                    }
               
            }
            
        }
        return diagnostics
    }
}


struct RequiredSecuritySchemeComponentsNamessRule: Rule {
    let name = "OAS.SecuritySchemaComponentName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        // falls spec.paths optional wäre – bei dir scheint es non-optional zu sein
        guard let schemas = spec.components?.securitySchemas else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
             
                    if !key.matches("[a-zA-Z0-9\\-\\._]+") {
                        diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\-\\._]+$'", pointer: "#/components/securitySchemes/\(key)", rule: name))
                    }
            }
            
        }
        return diagnostics
    }
}

struct RequiredLinksComponentsNamessRule: Rule {
    let name = "OAS.LinkComponentName"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        // falls spec.paths optional wäre – bei dir scheint es non-optional zu sein
        guard let schemas = spec.components?.links else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
               
                    if !key.matches("[a-zA-Z0-9\\.\\-_]+") {
                        diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\.\\-_]+$'", pointer: "#/components/links/\(key)", rule: name))
                    }
               
            }
            
        }
        return diagnostics
    }
}

struct RequiredCallBackomponentsNamessRule: Rule {
    let name = "OAS.CallbackComponentNames"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        // falls spec.paths optional wäre – bei dir scheint es non-optional zu sein
        guard let schemas = spec.components?.callbacks else { return diagnostics }
        for schema in schemas {
            if let key = schema.key {
                if !key.matches("[a-zA-Z0-9\\.\\-_]+") {
                    diagnostics.append(.init(severity: .error, code: .invalidValue, message: "component name not valid: must match: '^[a-zA-Z0-9\\.\\-_]+$'", pointer: "#/components/callbacks/\(key)", rule: name))
                }
            }
            
        }
        return diagnostics
    }
}

struct PathsMustStartWithSlashRule: Rule {
    let name = "OAS.PathsMustStartWithSlashRule"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        // falls spec.paths optional wäre – bei dir scheint es non-optional zu sein
        for path in spec.paths {
            
            if let key = path.key,
               !key.hasPrefix("/") {
                diagnostics.append(.init(severity: .error, code: .invalidValue, message: "path must start with a '/'", pointer: "/paths/\(key)", rule: name))
            }
        }
        return diagnostics
    }
}

struct SupportedHTTPMethodRule: Rule {
    let name = "OAS.SupportedHTTPMethodRule"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        let supportedMethods = ["get", "put", "post", "delete", "options", "head", "patch", "trace"]
        for path in spec.paths {
            
            for (operation) in path.operations where !supportedMethods.contains(operation.key ?? "nil") {
                diagnostics.append(.init(severity: .error, code: .invalidValue, message: "http operation not supported: '\(operation.key ?? "")'", pointer: "#/paths\(path.key ?? "")", rule: name))
            }
        }
        return diagnostics
    }
}
struct WebhookSupport30Rule: Rule {
    let name = "OASWebhookSupport"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        if spec.webhooks.count > 0 {
            let diagnotic = Diagnostic( severity: .error,
                                         code: .invalidElement,
            message: "Webhooks are not supported in OAS 3.0",
            pointer: "#/webhooks",
            rule: name)
            diags.append(diagnotic)
        }
        
        return diags
    }
    
}
struct OperationMustHaveResponsesRule: Rule {
    let name = "OAS.OperationMustHaveResponses"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []

        for pathItem in spec.paths {
            for op in pathItem.operations {
                
                guard op.responses.count > 0 else {
                    let diagnotics = Diagnostic( severity: .error,
                                                 code: .missingResponses,
                                                 message: "The Responses Object MUST contain at least one response code, and it SHOULD be the response for a successful operation call.",
                                                 pointer: JSONPointer.join("#/paths",JSONPointer.join(pathItem.key ?? "", "responses")),
                                                 rule: name)
                    diags.append(diagnotics)
                    break
                }
            }
        }
        return diags
    }
}


struct ExternalDocumentationMustHaveURLRule: Rule {
    let name = "OAS.ExternalDocumentationMustHaveURL"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        guard let externalDocumentations = spec.externalDocumentation else { return diags }
        if externalDocumentations.url == nil {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "External documentation must define a url.",
                                         pointer: "#/components/externalDocumentation/url",
                                         rule: name)
            diags.append(diagnotics)
        }
        
        return diags
    }
}

struct ParameterLocationsMustHaveInRule: Rule {
    let name = "OAS.ParameterLocationsMustHaveIn"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        guard let parameters = spec.components?.parameters else { return diags }
        for parameter in parameters {
            if parameter.location == nil {
                let diagnostic = Diagnostic( severity: .error,
                                             code: .missingRequired,
                                             message: "Parameters must be one of: 'query','queryString','header','path',cookie'.",
                                             pointer: "#/components/parameters/\(parameter.key ?? "")",
                                             rule: name)
                diags.append(diagnostic)
                if parameter.location == .path {
                    if parameter.required == false {
                        let diagnostic = Diagnostic( severity: .error,
                                                     code: .missingRequired,
                                                     message: "Path Parameters MUST BE required.",
                                                     pointer: "#/components/parameters/\(parameter.key ?? "")",
                                                     rule: name)
                        diags.append(diagnostic)
                    }
                }
              
            }
        }
        
        return diags
    }
}
struct RequestBodiesMustHaveContentRule: Rule {
    let name = "OAS.RequestBodiesMustHaveContent"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        guard let requestBodies = spec.components?.requestBodies else { return diags }
        for requestBody in requestBodies {
            if requestBody.contents.count == 0{
                let diagnotics = Diagnostic( severity: .error,
                                             code: .missingRequired,
                                             message: "Request Bodies must have  content.",
                                             pointer: "#/components/requestBodies/\(requestBody.key ?? "")",
                                             rule: name)
                diags.append(diagnotics)
            }
        }
        
        
        return diags
    }
}

struct ResponsesMustHaveDescriptionRule: Rule {
    let name = "OAS.ResponsesMustHaveDesccription"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        
        for info in RuleRunner.responseInfo(spec: spec) {
            let pointer = info.pointer
            let response = info.item
            if response.description == nil {
                let diagnotics = Diagnostic( severity: .error,
                                             code: .missingRequired,
                                             message: "Response must have description.",
                                             pointer: pointer,
                                             rule: name)
                diags.append(diagnotics)
            }
            else if let description = response.description,
                    description.isEmpty{
                let diagnotics = Diagnostic( severity: .error,
                                             code: .missingRequired,
                                             message: "Response must have description.",
                                             pointer: pointer,
                                             rule: name)
                diags.append(diagnotics)
            }
        }
        
        
        return diags
    }
}
struct OpenAPIResponse30_ValidFieldsRule: Rule {
    let name = "OpenAPIResponse30_ValidFieldsRule"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        for info in RuleRunner.responseInfo(spec: spec) {
            let pointer = info.pointer
            let response = info.item
                    if  response.summary != nil || !(response.summary ?? "").isEmpty{
                        let diagnotics = Diagnostic( severity: .error,
                                                     code: .missingRequired,
                                                     message: "Response does not support 'summary' in OpenAPI 3.0/3.1",
                                                     pointer: pointer,
                                                     rule: name)
                        diags.append(diagnotics)
                }
        }
       
        
        return diags
    }
}
struct SupportedHTPStatusRule: Rule {
    let name = "OAS.SupportedHTPStatusRule"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
          
        for info in RuleRunner.responseInfo(spec: spec) {
            let pointer = info.pointer
            let response = info.item
                    guard let key = response.key else {
                        continue
                    }
                    if !key.matches("^[1-5](?:\\d{2}|XX)$") && key != "default" {
                        diags.append(Diagnostic(severity: .error,
                                                code: .invalidValue,
                                                message: "Response code '\(key)' is not a valid HTTP status code.",
                                                pointer: pointer,
                                                rule: name))
                }
                    
            }
           
        
        return diags
    }
}




struct LinkMustHaveRefOrIdentifier: Rule {
    let name = "OAS.LinkMustHaveRefOrIdentifier"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        guard let links = spec.components?.links else { return diags }
        for link in links {
            if link.ref == nil && (link.key == nil || (link.key ?? "").isEmpty) {
                let diagnotics = Diagnostic( severity: .error,
                                             code: .missingRequired,
                                             message: "Request Bodies must have  content.",
                                             pointer: "#/components/links/\(link.key ?? "")",
                                             rule: name)
                diags.append(diagnotics)
            }
        }
        
        
        return diags
    }
}


struct TagMustHaveName: Rule {
    let name = "OAS.TagMustHaveName"

    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
       
        for tag in spec.tags {
            if tag.key == nil || (tag.key ?? "").isEmpty {
                let diagnotics = Diagnostic( severity: .error,
                                             code: .missingRequired,
                                             message: "Tag needs an mae",
                                             pointer: "#/tags/\(tag.key ?? "")",
                                             rule: name)
                diags.append(diagnotics)
            }
        }
        
        
        return diags
    }
}

struct ReferencesMustHaveRefRule : Rule {
    let name = "OAS.ReferencesMustHaveRef"
    
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        
        if let headers = spec.components?.headers  {
            for header in headers {
                let pointer = "#/components/headers/"
                diags.append(contentsOf:  ReusableHeaderRefRule().check(header: header, ctx: ctx,  pointer: pointer ,rule: name))
            }
        }
        if let callbacks = spec.components?.callbacks {
            for callback in callbacks {
                let pointer = "#/components/callbacks/"
                diags.append(contentsOf:  ReusableCallbackRefRule().check(callback: callback,ctx: ctx,  pointer: pointer ,rule: name))
            }
        }
        if let examples = spec.components?.examples {
            for example in examples {
                let pointer = "#/components/examples"
                diags.append(contentsOf: ReusableExampleRefRule().check(example : example, ctx: ctx, pointer: pointer, rule: name))
            }
        }
        if let links = spec.components?.links  {
            for link in links {
                let pointer = "#/components/links/"
                diags.append(contentsOf:  ReusableLinkRefRule().check(link: link, ctx: ctx,  pointer: pointer ,rule: name))
            }
        }
        if let requestBodies = spec.components?.requestBodies {
            for requestBody in requestBodies{
                let pointer = "#/components/requestBodies/"
                diags.append(contentsOf: ReusableRequestBodyRefRule().check(requestBody: requestBody, ctx: ctx, pointer: pointer, rule: name))
            }
        }
        if let responses = spec.components?.responses {
            for response in responses {
                let pointer = "#/components/responses/"
                diags.append(contentsOf: ReusableResponseRefRule().check(response: response, ctx: ctx, pointer: pointer, rule: name))
            }
        }
        if let schemacomponents =  spec.components?.schemas  {
            for schema in schemacomponents {
                let pointer =  "#/components/schemas\(schema.key ?? "")"
                diags.append(contentsOf: ReusableNamedSchemaRefRule().check(schema: schema, ctx: ctx, pointer: pointer, rule: name))
            }
        }
        
        if let parameters = spec.components?.parameters {
            for parameter in parameters {
                let pointer = "#/components/parameter/"
                diags.append(contentsOf: ReusableParameterRefRule().check(parameter: parameter, ctx: ctx, pointer: pointer, rule: name))
            }
        }
        for path in spec.paths {
            if path.ref == nil && path.operations.isEmpty {
                let diagnotics = Diagnostic( severity: .error,
                                             code: .missingRequired,
                                             message: "Path needs a ref or an operation",
                                             pointer: "#/paths\(path.key ?? "")",
                                             rule: name)
                diags.append(diagnotics)
            }
            else {
                for operation in path.operations {
                    diags.append(contentsOf: ReusableOperationRefRule().check(operation: operation, ctx: ctx, pointer: "/paths\(path.key ?? "")", rule: name))
                }
            }
         
        }
        return diags
    }
    
}
/*
 let baseRules: [Rule] = [RequiredInfoRule(), RequiredPathsRule(), ...]
 let v30Rules: [Rule] = baseRules + [OAS30NullableRule(), ...]
 let v31Rules: [Rule] = baseRules + [JSONSchemaDialectRule(), ...]
 let v32Rules: [Rule] = baseRules + [OAS32SpecificRule(), ...]

 */

// Einfache Rule, die in Tests/Validator referenziert wird: paths darf nicht leer sein.
struct RequiredPathsRule: Rule {
    let name = "OAS.RequiredPaths"
    func check(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        guard spec.paths.isEmpty == false else {
            return [.init(severity: .error,
                          code: .missingRequired,
                          message: "Missing required field 'paths' or it is empty.",
                          pointer: "#/paths",
                          rule: name)]
        }
        return []
    }
}

extension String {
    // Checks if the whole string is matched by the pattern
    func matches(_ pattern: String) -> Bool {
        if #available(macOS 13.0, *) {
            guard let regex = try? Regex(pattern) else { return false }
            return self.wholeMatch(of: regex) != nil
        } else {
            do {
                let regex = try NSRegularExpression(pattern: "^\(pattern)$")
                let range = NSRange(self.startIndex..<self.endIndex, in: self)
                return regex.firstMatch(in: self, options: [], range: range) != nil
            } catch {
                return false
            }
        }
    }
    func isValidRegex() -> Bool {
        
        if #available(macOS 13.0, *) {

            guard ((try? Regex(self)) != nil) else { return false }

            return true
        }
        else {
            do {
                let regex = try NSRegularExpression(pattern: "^\(self)$")
                let range = NSRange(self.startIndex..<self.endIndex, in: self)
                return regex.firstMatch(in: self, options: [], range: range) != nil
            } catch {
                return false
            }
        }
    }
}


