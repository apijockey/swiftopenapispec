//
//  ReusableRequestBodyRefPointerRule.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 05.01.26.
//


struct ReusableCallbackRefPointerRule {
    func check(callback : OpenAPICallBack, ctx: ValidationContext, pointer : String, rule: String) -> [RefOccurrence] {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/callbacks/\(callback.key ?? "")"
        occurrences += SchemaRefCollector().collect(from: callback.ref, pointer: pointer)
       
        return occurrences
    }
}
struct ReusableExampleRefPointerRule {
    func check(example : OpenAPIExample, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence] {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/\(example.key ?? "")"
        if let ref = example.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
       
        return occurrences
    }
}

struct ReusableHeaderRefPointerRule {
    func check(header : OpenAPIHeader, ctx: ValidationContext, pointer : String, rule: String) -> [RefOccurrence] {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/\(header.key ?? "")"
        if let ref = header.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
        else if let content = header.content {
                occurrences +=  ReusableMediaTypeRefPointerRule().check(content: content, ctx: ctx, pointer: pointer, rule: rule)
            
        }
        return occurrences
    }
}
struct ReusableLinkRefPointerRule {
    func check(link : OpenAPILink, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence] {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/links/\(link.key ?? "")"
        
        if let ref = link.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
       
        return occurrences
    }
}
struct ReusableMediaTypeRefPointerRule {
    func check(content : OpenAPIMediaType, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence]  {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/\(content.key ?? "")"
        if let ref = content.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
        else if let schema = content.schema {
            occurrences += ReusableSchemaRefPointerRule().check(schema: schema, ctx: ctx, pointer: pointer, rule: rule)
        }
        return occurrences
    }
}

struct ReusableOperationRefPointerRule {
    func check(operation : OpenAPIOperation, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence] {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/\(operation.key ?? "")"
        if let ref = operation.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
        if let parameters = operation.parameters {
            for parameter in parameters {
                occurrences += ReusableParameterRefPointerRule().check(parameter: parameter, ctx: ctx, pointer: pointer, rule: rule)
            }
        }
        if let requestBody = operation.requestBody{
            
            occurrences += ReusableRequestBodyRefPointerRule().check(requestBody: requestBody, ctx: ctx, pointer: pointer, rule: rule)
            
        }
        if let responses = operation.responses{
            for response in responses {
                occurrences += ReusableResponseRefPointerRule().check(response: response, ctx: ctx, pointer: pointer, rule: rule)
            }
        }
        if let callbacks = operation.callbacks{
            for callback in callbacks {
                occurrences += ReusableCallbackRefPointerRule().check(callback: callback, ctx: ctx, pointer: pointer, rule: rule)
            }
            
            
        }
     
        return occurrences
    }
}


struct ReusableParameterRefPointerRule {
    func check(parameter: OpenAPIParameter, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence]  {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/\(parameter.key ?? "")"
        if let ref = parameter.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
        else {
            if let schema = parameter.schema {
                occurrences += ReusableSchemaRefPointerRule().check(schema: schema, ctx: ctx, pointer: pointer, rule: rule)
                
            }
            if let examples = parameter.examples {
                for example in examples {
                    occurrences += ReusableExampleRefPointerRule().check(example: example, ctx: ctx, pointer: pointer, rule: rule)
                }
            }
        }
        return occurrences
    }
}



struct ReusableRequestBodyRefPointerRule {
    func check(requestBody : OpenAPIRequestBody, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence]  {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/requestBodies/\(requestBody.key ?? "")"
        
        if let ref = requestBody.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
        else {
                for content in requestBody.contents {
                    occurrences += ReusableMediaTypeRefPointerRule().check(content: content, ctx: ctx, pointer: pointer, rule: rule)
                }
        }
        return occurrences
    }
}
struct ReusableResponseRefPointerRule {
    func check(response : OpenAPIResponse, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence]  {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/\(response.key ?? "")"
        if let ref = response.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
        else if response.content.count > 0 {
            for content in response.content {

                occurrences += ReusableMediaTypeRefPointerRule().check(content: content, ctx: ctx, pointer: pointer, rule: rule)
            }
            
        }
        return occurrences
    }
}

struct ReusableSchemaRefPointerRule {
    func check(schema : OpenAPISchema, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence]  {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/\(schema.key ?? "")"
        
        if let ref = schema.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
        return occurrences
    }
}



struct ReusableSecuritySchemaRefPointerRule {
    func check(securitySchema : OpenAPISecurityScheme, ctx: ValidationContext, pointer : String, rule: String) ->  [RefOccurrence]  {
        var occurrences: [RefOccurrence] = []
        let pointer =  "\(pointer)/securitySchemes/\(securitySchema.key ?? "")"
        
        if let ref = securitySchema.ref {
            occurrences += SchemaRefCollector().collect(from: ref, pointer: pointer)
        }
       
        return occurrences
    }
}




