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

    
    public func collect(from content : OpenAPIMediaType, pointer : String)  -> [RefOccurrence] {
        var out: [RefOccurrence] = []
        if let r = content.ref?.refString {
            out.append(.init(
                refString: r,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
        }
        else if let schema = content.schema,
                    let ref = schema.ref {
            out.append(.init(
                refString: ref.refString,
                pointerToDollarRef: JSONPointer.join(pointer, "$ref"),
                expected: .schemaObject
            ))
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
            for content in response.content {
                out.append(contentsOf: collect(from: content, pointer: JSONPointer.join(pointer, "$eref")))
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
                   let schemaType = prop.schemaOrSelf {
                    let propPtr = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                    out.append(contentsOf: collect(fromSchemaType: schemaType , pointer: propPtr))
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
