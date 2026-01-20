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
// Collect $ref occurrences from OpenAPISchema and nested schema types.
//
// Supports:
// - OpenAPISchema.ref (wrapper-level)
// - OpenAPISchemaReference as a schemaType (e.g. inside anyOf/oneOf/allOf items)
// - Object properties: OpenAPIObjectType.properties: [OpenAPISchemaProperty] (KeyedElement)
// - Array items: OpenAPIArrayType.items
// - anyOf / oneOf / allOf composition types: OpenAPIAnyOfType / OpenAPIOneOfType / OpenAPIAllOfType

public struct SchemaRefCollector {

    public init() {}

    /*
     for response in responses {
             let path = "/paths/\(JSONPointer.escape(path.key ?? ""))/operations/\(op.key ?? "")" + "/responses/\(response.key ?? "")"
             occurrences += SchemaRefCollector().collect(from: response, pointer: path)
     }
     */
    
    public func collect(from path :OpenAPIPathItem, pointer : String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = path.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
            return out
        }
        for operation in path.operations{
            let pointer = pointer + "/" + (operation.key ?? operation.operationId ?? "")
            out.append(contentsOf: collect(from: operation, pointer: pointer))
        }
        
        return out
    }
    public func collect(from op : OpenAPIOperation , pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = op.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        else  {
            if let parameters = op.parameters {
                for parameter in parameters {
                    out.append(contentsOf: collect(from: parameter, pointer: JSONPointer.join(pointer, "parameters")))
                }
                
            }
            if let requestBody = op.requestBody {
                out.append(contentsOf:collect(from: requestBody, pointer: JSONPointer.join(pointer, "requestBody")))
            }
            for response in (op.responses ?? []){
                    let ptr = pointer + "/responses/" + (response.key ?? "")
                    out.append(contentsOf: collect(from: response, pointer: ptr))
            }
                
        }
        return out
    }
    public func collect(from content : OpenAPIMediaType, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = content.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        else if let schema = content.schema {
            out.append(contentsOf: collect(from: schema, pointer: JSONPointer.join(pointer, "schema")))
        
        }
        return out
    }
    public func collect(from response : OpenAPIResponse, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = response.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        else
        {
            
            for header in response.headers {
                let ptr = pointer + "/headers/" + (header.key ?? "")
                out.append(contentsOf:collect(from: header, pointer:ptr))
            }
            
            for content in response.content {
                let ptr = pointer + "/content/" + (JSONPointer.escape(content.key ?? ""))
                out.append(contentsOf:collect(from: content, pointer:  ptr))
            }
            for link in response.links {
                let ptr = pointer + "links/" + (link.operationId ?? "")
                out.append(contentsOf:collect(from: link, pointer: ptr))
            }
            
        }
        return out
    }
    public func collect(from example : OpenAPIExample, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = example.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        
        return out
    }
    public func collect(from link : OpenAPILink, pointer : String)  -> [RefOccurrence] {
    var out: [RefOccurrence] = []
    if let r = link.ref?.refString {
        out.append(.init(
            refString: r,
            pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
            expected: .schemaObject
        ))
    }
    
    return out
    }
    
    public func collect(from securityScheme : OpenAPISecurityScheme, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = securityScheme.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        
        return out
    }
    public func collect(from encoding : OpenAPIEncoding, pointer : String)  -> [RefOccurrence] {
    var out: [RefOccurrence] = []
    if let r = encoding.ref?.refString {
        out.append(.init(
            refString: r,
            pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
            expected: .schemaObject
        ))
    }
        else {
            for header in (encoding.headers ?? []) {
                let ptr = pointer + "encoding/" + (header.key ?? "")
                out.append(contentsOf: collect(from: header, pointer: ptr))
            }
        }
    
    return out
    }
    public func collect(from callback : OpenAPICallBack, pointer : String)  -> [RefOccurrence] {
    var out: [RefOccurrence] = []
    if let r = callback.ref?.refString {
        out.append(.init(
            refString: r,
            pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
            expected: .schemaObject
        ))
    }
        else {
            for path in (callback.pathItems ?? []) {
                let ptr = pointer + "callback/" + JSONPointer.escape(path.key ?? "")
                out.append(contentsOf: collect(from: path, pointer:ptr))
            }
        }
    
    return out
    }
    
    public func collect(from parameter : OpenAPIParameter, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = parameter.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        else {
            if let schema = parameter.schema {
                out.append(contentsOf: collect(from: schema, pointer: JSONPointer.join(pointer, "schema")))
            }
        }
        
        return out
    }
    public func collect(from header : OpenAPIHeader, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = header.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        else {
            if let schema = header.schema {
                out.append(contentsOf: collect(from: schema, pointer: JSONPointer.join(pointer, "schema")))
            }
        }
        
        return out
    }
    public func collect(from request: OpenAPIRequestBody, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = request.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        else
        {
            
            for content in (request.contents) {
                let ptr = pointer + "/content/\(JSONPointer.escape(content.key ?? ""))"
                out.append(contentsOf:collect(from: content, pointer: ptr))
            }
            
        }
        return out
    }
    public func collect(from schema: OpenAPISchema, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []

        // A) $ref on schema wrapper
        if let r = schema.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
            return out
        }

        // B) walk into schemaType
        if let t = schema.schemaType {
            out.append(contentsOf: collect(fromSchemaType: t, pointer: pointer))
        }

        return out
    }
    
    public func collect(from ref : OpenAPISchemaReference?, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []

        // A) $ref on schema wrapper
        if let ref = ref?.refString {
            out.append(.init(
                refString: ref,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
            return out
        }
        return out
    }

    public func collect(fromSchemaType schemaType: any OpenAPIValidatableSchemaType, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []

        // 1) $ref as schemaType (common inside composition items)
        if let refType = schemaType as? OpenAPISchemaReference {
            out.append(.init(
                refString: refType.refString,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
            return out
        }

        // 2) Object -> properties
        if let obj = schemaType as? OpenAPIObjectType {
            for prop in obj.properties {
                if let key = prop.key,
                   let ref = prop.ref {
                    let propPtr = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                    out.append(.init(
                        refString: ref.refString,
                        pointerToDollarRef: JSONPointer.join(propPtr, "\(key)/$ref"),
                        expected: .schemaObject
                    ))
                }
                
                else if let type = prop.type,
                        let key = prop.key{
                    let propPtr = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                    out.append(contentsOf: collect(fromSchemaType: type  , pointer: JSONPointer.join(propPtr, "\(key)/")))
                }
            }
            
        }

        // 3) Array -> items
        if let arr = schemaType as? OpenAPIArrayType, let items = arr.items {
            out.append(contentsOf: collect(fromSchemaType: items, pointer: JSONPointer.join(pointer, "items")))
        }

        // 4) anyOf
        if let anyOf = schemaType as? OpenAPIAnyOfType, let items = anyOf.items {
            for (idx, item) in items.enumerated() {
                let itemPtr = JSONPointer.join(JSONPointer.join(pointer, "anyOf"), "\(idx)")
                out.append(contentsOf: collect(fromSchemaType: item, pointer: itemPtr))
            }
        }

        // 5) oneOf
        if let oneOf = schemaType as? OpenAPIOneOfType, let items = oneOf.items {
            for (idx, item) in items.enumerated() {
                let itemPtr = JSONPointer.join(JSONPointer.join(pointer, "oneOf"), "\(idx)")
                out.append(contentsOf: collect(fromSchemaType: item, pointer: itemPtr))
            }
        }

        // 6) allOf
        if let allOf = schemaType as? OpenAPIAllOfType, let items = allOf.items {
            for (idx, item) in items.enumerated() {
                let itemPtr = JSONPointer.join(JSONPointer.join(pointer, "allOf"), "\(idx)")
                out.append(contentsOf: collect(fromSchemaType: item, pointer: itemPtr))
            }
        }

        return out
    }
}

// Adapter helpers.
public extension OpenAPISchemaProperty {
    var schemaOrSelf: (any OpenAPIValidatableSchemaType)?{
       
        return self.type
    }
}

public extension OpenAPISchemaReference {
    var refString: String {
        
        return self.reference ?? ""
    }
}
