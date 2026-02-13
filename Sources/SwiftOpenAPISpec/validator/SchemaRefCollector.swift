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

/// Collects reference (`$ref`) occurrences from OpenAPI schemas and nested structures.
/// 
/// This collector is a specialized component that traverses OpenAPI schema definitions
/// to find and catalog all reference occurrences. It plays a crucial role in:
/// - Reference resolution and validation
/// - Circular reference detection
/// - Dependency analysis
/// - Schema composition analysis
///
/// The collector supports a comprehensive range of reference locations:
/// - Schema-level references (`OpenAPISchema.ref`)
/// - Schema references as types (`OpenAPISchemaReference`)
/// - Object properties (`OpenAPIObjectType.properties`)
/// - Array items (`OpenAPIArrayType.items`)
/// - Composition types (`anyOf`, `oneOf`, `allOf`)
/// - Nested structures within compositions
///
/// - Note: The collector is designed to be thorough and will traverse
///         deeply nested schema structures to ensure no references are missed.
public struct SchemaRefCollector {

    /// Initializes a new schema reference collector.
    /// 
    /// - Returns: A new `SchemaRefCollector` instance ready to traverse schemas
    public init() {}


    
    /// Collects references from an OpenAPI path item.
    /// 
    /// This method traverses a path item and its associated operations to find
    /// all reference occurrences.
    /// 
    /// - Parameters:
    ///   - path: The `OpenAPIPathItem` to analyze
    ///   - pointer: The base JSON Pointer to the path item
    /// - Returns: An array of `RefOccurrence` objects found in the path item
    /// 
    /// The method examines:
    /// - Path-level references
    /// - References in all HTTP methods (GET, POST, PUT, etc.)
    /// - Parameters, request bodies, and responses
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
       
            
                for parameter in op.parameters {
                    out.append(contentsOf: collect(from: parameter, pointer: JSONPointer.join(pointer, "parameters")))
                }
                
            
            if let requestBody = op.requestBody {
                out.append(contentsOf:collect(from: requestBody, pointer: JSONPointer.join(pointer, "requestBody")))
            }
            for response in (op.responses){
                    let ptr = pointer + "/responses/" + (response.key ?? "")
                    out.append(contentsOf: collect(from: response, pointer: ptr))
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

            for header in (encoding.headers) {

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
        if let r = parameter.ref?.reference {
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
        if let r = header.ref?.reference {
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
        if let r = request.ref?.reference {
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
    public func collect(from obj: OpenAPIArrayType, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        
        if let items = obj.items {
            
                let itemPtr = JSONPointer.join(pointer, "items")
                out.append(contentsOf: collect(from: items, pointer: itemPtr))
            
        }
        return out
    }
    public func collect(from obj: OpenAPIAnyOfType, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let ref = obj.ref {
            out.append(.init(
                refString: ref.reference ?? "",
                pointerToDollarRef: JSONPointer.join(pointer, "/$ref"),
                expected: .schemaObject
            ))
            return out
        }
        if let items = obj.items {
            for (idx, item) in (items.enumerated()) {
                let itemPtr = JSONPointer.join(pointer, "\(idx)")
                out.append(contentsOf: collect(from: item, pointer: itemPtr))
            }
        }
        return out
    }
    public func collect(from obj: OpenAPIOneOfType, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let ref = obj.ref {
            out.append(.init(
                refString: ref.reference ?? "",
                pointerToDollarRef: JSONPointer.join(pointer, "/$ref"),
                expected: .schemaObject
            ))
            return out
        }
        if let items = obj.items {
            for (idx, item) in (items.enumerated()) {
                let itemPtr = JSONPointer.join(pointer, "\(idx)")
                out.append(contentsOf: collect(from: item, pointer: itemPtr))
            }
        }
        return out
    }
    public func collect(from obj: OpenAPIAllOfType, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let ref = obj.ref {
            out.append(.init(
                refString: ref.reference ?? "",
                pointerToDollarRef: JSONPointer.join(pointer, "/$ref"),
                expected: .schemaObject
            ))
            return out
        }
        if let items = obj.items {
            for (idx, item) in (items.enumerated()) {
                let itemPtr = JSONPointer.join(pointer, "\(idx)")
                out.append(contentsOf: collect(from: item, pointer: itemPtr))
            }
        }
        return out
    }
    public func collect(from obj: OpenAPIObjectType, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        for prop in obj.properties {
            if let key = prop.key,
               case let .ref(ref) = prop.type {
                let propPtr = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                out.append(.init(
                    refString: ref.reference ?? "",
                    pointerToDollarRef: JSONPointer.join(propPtr, "\(key)/$ref"),
                    expected: .schemaObject
                ))
            }
            
            else if let key = prop.key{
                let propPtr = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                out.append(contentsOf: collect(from:  prop  , pointer: JSONPointer.join(propPtr, "\(key)/")))
            }
        }
        
        for prop in obj.additionalPropertiesObject {
            if let key = prop.key,
               case let .ref(ref) = prop.type {
                let propPtr = JSONPointer.join(JSONPointer.join(pointer, "additionalProperties"), key)
                out.append(.init(
                    refString: ref.reference ?? "",
                    pointerToDollarRef: JSONPointer.join(propPtr, "\(key)/$ref"),
                    expected: .schemaObject
                ))
            }
            
            else if let key = prop.key{
                let propPtr = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                out.append(contentsOf: collect(from:  prop  , pointer: JSONPointer.join(propPtr, "\(key)/")))
            }
        }
        return out
    }
    /// Collects references from an OpenAPI schema.
    /// 
    /// This is the main method that traverses an OpenAPI schema and its nested structures
    /// to find all reference occurrences. It handles all schema types and compositions.
    /// 
    /// - Parameters:
    ///   - schema: The `OpenAPISchema` to analyze
    ///   - pointer: The base JSON Pointer to the schema
    /// - Returns: An array of `RefOccurrence` objects found in the schema and its children
    /// 
    /// The method recursively examines:
    /// - Schema-level references (`schema.ref`)
    /// - All schema types (object, array, string, number, etc.)
    /// - Composition types (allOf, anyOf, oneOf)
    /// - Nested properties and items
    /// - Reference types (`OpenAPISchemaReference`)
    ///
    /// This method serves as the entry point for most schema reference collection
    /// and is called by other collection methods for specific OpenAPI elements.
    public func collect(from schema: OpenAPISchema, pointer: String) -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        switch schema.type {
        case .allOf(let openAPIAllOfType):
            out.append(contentsOf: collect(from: openAPIAllOfType, pointer: JSONPointer.join(pointer, "allOf")))
        case .anyOf(let openAPIAnyOfType):
            out.append(contentsOf: collect(from: openAPIAnyOfType, pointer: JSONPointer.join(pointer, "anyOf")))
        case .array(let openAPIArrayType):
            out.append(contentsOf: collect(from: openAPIArrayType, pointer: JSONPointer.join(pointer, "array")))
        case .bool:
            return out
        case .integer:
            return out
        case .number:
            return out
        case .object(let openAPIObjectType):
            out.append(contentsOf: collect(from: openAPIObjectType, pointer: pointer))
        case .oneOf(let openAPIOneOfType):
            out.append(contentsOf: collect(from: openAPIOneOfType, pointer: JSONPointer.join(pointer, "oneOf")))
        case .string:
            return out
        case .ref(let openAPISchemaReference):
            out.append(.init(
                refString: openAPISchemaReference.refString,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
            return out
        case .null:
            return []
        case .none:
            return []
        case .some(.unknown(_)):
            return []
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

    
}

public extension OpenAPISchemaReference {
    var refString: String {
        
        return self.reference ?? ""
    }
}
