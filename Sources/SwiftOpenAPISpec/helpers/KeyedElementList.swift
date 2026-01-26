//
//  which.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 23.01.26.
//


/// Helper struct which maps  a dictionary of Elements with a unique identifier like a name  to a list of values
public struct KeyedElementList<T> where T :  KeyedElement {
    
    /// Creates a list of elements with a unique `key` element from the keys in the dictinary with elements that hold  the `values`contents in its properties
    /// - Parameter elements: an ordinary Dictionary<String,Any>
    /// - Returns: a list of elements or throws an error if any element  of type `T` cannot be created
    
    @available(*, deprecated, message: "use StringDictionary.readIfPresent")
    static func map(_ elements : StringDictionary) throws -> InitializationResult<[T]> {
        var types = [T]()
        var diagnostics: [Diagnostic] = []
        for element in elements {
            let value = element.value
            if case let .object(valueMap) = value {
                var type = try T.initialize(valueMap)
                type.value.key = element.key
                diagnostics.append(contentsOf:type.diagnostics)
                types.append(type.value)
            }
        }
        return InitializationResult(value: types, diagnostics: diagnostics)
    }
//    static func map(list : [StringDictionary], yamlKeyName : String, mayHaveRef : Bool) throws -> InitializationResult<[T]> {
//        var types = [T]()
//        var diagnostics: [Diagnostic] = []
//        for listElement in list {
//            var element = try T.initialize(listElement)
//            diagnostics.append(contentsOf:element.diagnostics)
//                if case let .string(key) = listElement[yamlKeyName] {
//                    element.value.key = key
//                    types.append(element.value)
//                }
//                else if mayHaveRef == true {
//                    if case let .object(reference) = listElement["$ref"]  {
//                        var schemaReferenceable = reference as? OpenAPISchemaReferenceable
//                        if schemaReferenceable != nil {
//                            schemaReferenceable?.ref = try OpenAPISchemaReference(load: reference)
//                        }
//                    }
//                }
//                else {
//                    throw OpenAPISpecification.Errors.invalidYaml("Could not find a entry in \(list.debugDescription) for \(yamlKeyName)")
//                }
//        }
//        return  InitializationResult(value: types, diagnostics: diagnostics)
//        
//    }
    
}
