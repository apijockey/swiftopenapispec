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
    static func map(_ elements : StringDictionary,pointer : String) throws -> InitializationResult<[T]> {
        var types = [T]()
        var diagnostics: [Diagnostic] = []
        for element in elements {
            let value = element.value
            if case let .object(valueMap) = value {
                var initializationResult = try T.initialize(load: valueMap, diagnostics: &diagnostics, pointer: pointer)
                initializationResult.value.key = element.key
                diagnostics.append(contentsOf:initializationResult.diagnostics)
                types.append(initializationResult.value)
            }
        }
        return InitializationResult(value: types, diagnostics: diagnostics)
    }
}
