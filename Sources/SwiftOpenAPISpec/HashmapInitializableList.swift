//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/// Helper struct which maps  a Yaml-List / JSON-Array to Swift-Array
public struct HashmapInitializableList<T> where T : ThrowingHashMapInitiable {
    
    /// Creates a list of elements from a Yaml-List / JSON-Array 
    /// - Parameter a Yaml-List / JSON-Array
    /// - Returns: a Swift Array or  throws an error if any element  of type `T` cannot be created
    static func map(_ list:  [Any]) throws -> [T] {
        var types = [T]()
        for element in list {
            if let elementMap = element as? StringDictionary {
                let element = try T(elementMap)
                types.append(element)
            }
        }
        return types
    }
    
}



/// Helper struct which maps  a dictionary of Elements with a unique identifier like a name  to a list of values
public struct KeyedElementList<T> where T :  KeyedElement {
    
    /// Creates a list of elements with a unique `key` element from the keys in the dictinary with elements that hold  the `values`contents in its properties
    /// - Parameter elements: an ordinary Dictionary<String,Any>
    /// - Returns: a list of elements or throws an error if any element  of type `T` cannot be created
    static func map(_ elements : StringDictionary) throws -> [T] {
        var types = [T]()
        for element in elements {
            let value = element.value
            if let valueMap = value as? StringDictionary{
                var type = try T(valueMap)
                type.key = element.key
                types.append(type)
            }
        }
        return types
    }
    
}


public protocol ThrowingHashMapInitiable {
    init(_ map : StringDictionary) throws
    var userInfos :  [OpenAPIObject.UserInfo] {get}
   
}
/**A KeyedElement expects that the key Value is set from outside**/
