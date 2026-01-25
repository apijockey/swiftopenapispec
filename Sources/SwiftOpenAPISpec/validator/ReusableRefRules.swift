//
//  ReusableRequestBodyRefRule.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 05.01.26.
//


struct ReusableCallbackRefRule {
    func check(callback : OpenAPICallBack, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/callbacks/\(callback.key ?? "")"
        
        if (callback.pathItems == nil || (callback.pathItems?.count ?? 0) == 0) && callback.ref  == nil {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "callback needs a pathItem or a reference object",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
       
        return diags
    }
}
struct ReusableExampleRefRule {
    func check(example : OpenAPIExample, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/\(example.key ?? "")"
        if example.ref == nil  && (example.description == nil && example.summary == nil && example.value == nil && example.externalValue == nil) {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Example needs a ref or example information",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
       
        return diags
    }
}

struct ReusableHeaderRefRule {
    func check(header : OpenAPIHeader, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/\(header.key ?? "")"
        if header.ref == nil  && header.content == nil {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Header needs a ref",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
        else if let content = header.content {
            
            diags.append(contentsOf: ReusableMediaTypeRefRule().check(content: content, ctx: ctx, pointer: pointer, rule: rule))
        }
        return diags
    }
}
struct ReusableLinkRefRule {
    func check(link : OpenAPILink, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/links/\(link.key ?? "")"
        
        if link.operationRef == nil && link.operationId == nil && link.requestBody == nil{
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Link needs an operation ref or operation id",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
        else {
        }
       
        return diags
    }
}
struct ReusableMediaTypeRefRule {
    func check(content : OpenAPIMediaType, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        
        let pointer =  "\(pointer)/\(content.key ?? "")"
        if content.ref == nil && content.schema == nil {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Content object needs a ref or a schema",
                                         pointer: pointer,
                                         rule:rule)
            diags.append(diagnotics)
        }
        else if let schema = content.schema {
            diags.append(contentsOf: ReusableSchemaRefRule().check(schema: schema, ctx: ctx, pointer: pointer, rule: rule))
        }
        return diags
    }
}

struct ReusableOperationRefRule {
    func check(operation : OpenAPIOperation, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/\(operation.key ?? "")"
        if operation.ref == nil  && (operation.operationId == nil  && operation.key == nil){
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Operation needs a ref or an operationId or a key",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
            return diags
        }
        if let parameters = operation.parameters {
            for parameter in parameters {
                diags.append(contentsOf: ReusableParameterRefRule().check(parameter: parameter, ctx: ctx, pointer: pointer, rule: rule))
            }
        }
        if let requestBody = operation.requestBody{
            
            diags.append(contentsOf: ReusableRequestBodyRefRule().check(requestBody: requestBody, ctx: ctx, pointer: pointer, rule: rule))
            
        }
        if let responses = operation.responses{
            for response in responses {
                diags.append(contentsOf: ReusableResponseRefRule().check(response: response, ctx: ctx, pointer: pointer, rule: rule))
            }
        }
        if let callbacks = operation.callbacks{
            for callback in callbacks {
                diags.append(contentsOf: ReusableCallbackRefRule().check(callback: callback, ctx: ctx, pointer: pointer, rule: rule))
            }
            
            
        }
     
        return diags
    }
}


struct ReusableParameterRefRule {
    func check(parameter: OpenAPIParameter, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/\(parameter.key ?? "")"
        if parameter.ref == nil  && parameter.schema == nil && parameter.content == nil {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Parameter needs a ref, a schema or a content object",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
        else {
            if let schema = parameter.schema {
                diags.append(contentsOf: ReusableSchemaRefRule().check(schema: schema, ctx: ctx, pointer: pointer, rule: rule))
                
            }
            if let examples = parameter.examples {
                for example in examples {
                    diags.append(contentsOf: ReusableExampleRefRule().check(example: example, ctx: ctx, pointer: pointer, rule: rule))
                }
            }
        }
        return diags
    }
}



struct ReusableRequestBodyRefRule {
    func check(requestBody : OpenAPIRequestBody, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/requestBodies/\(requestBody.key ?? "")"
        
        if requestBody.ref == nil && requestBody.contents.count == 0 {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Request Body needs a ref or contents",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
        else {
                for content in requestBody.contents {
                    diags.append(contentsOf: ReusableMediaTypeRefRule().check(content: content, ctx: ctx, pointer: pointer, rule: rule))
                }
        }
        return diags
    }
}
struct ReusableResponseRefRule {
    func check(response : OpenAPIResponse, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/\(response.key ?? "")"
        if response.ref == nil  && (response.description == nil){
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Response needs a ref or a response object with 'description'",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
        else if response.content.count > 0 {
            for content in response.content {

                diags.append(contentsOf: ReusableMediaTypeRefRule().check(content: content, ctx: ctx, pointer: pointer, rule: rule))
            }
            
        }
        return diags
    }
}

struct ReusableSchemaRefRule {
    func check(schema : OpenAPISchema, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        switch schema.type{
            case .allOf, .oneOf, .anyOf, .object, .array, .string, .integer, .bool, .number, .ref:
            return diags
            default:
                let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "schema needs a ref or a schema type",
                                         pointer: pointer,
                                         rule:rule)
            diags.append(diagnotics)
        }
        return diags
    }
}

struct ReusableNamedSchemaRefRule {
    func check(schema : OpenAPINamedSchema, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        guard let key = schema.key,
              let type = schema.schema?.type else {
            let diagnotics = Diagnostic( severity: .error,
                                     code: .missingRequired,
                                     message: "schema incomplete missing 'name' or 'type'",
                                     pointer: pointer,
                                     rule:rule)
            diags.append(diagnotics)
            return diags
        }
        let pointer =  "\(pointer)/schemas/\(key)"
        switch type{
            case .allOf, .oneOf, .anyOf, .object, .array, .string, .integer, .bool, .number, .ref:
            return diags
            default:
                let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "schema needs a ref or a schema type",
                                         pointer: pointer,
                                         rule:rule)
            diags.append(diagnotics)
        }
        return diags
    }
}



struct ReusableSecuritySchemaRefRule {
    func check(securitySchema : OpenAPISecurityScheme, ctx: ValidationContext, pointer : String, rule: String) -> [Diagnostic] {
        var diags: [Diagnostic] = []
        let pointer =  "\(pointer)/securitySchemes/\(securitySchema.key ?? "")"
        
        if securitySchema.ref == nil && securitySchema.securityType == nil {
            let diagnotics = Diagnostic( severity: .error,
                                         code: .missingRequired,
                                         message: "Security scheme needs a ref or contents",
                                         pointer: pointer,
                                         rule: rule)
            diags.append(diagnotics)
        }
       
        return diags
    }
}




