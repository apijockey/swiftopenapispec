//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
extension Dictionary where Key == String, Value == Any {
    
    /// Reads a dictionary value and transforms it to the specified type. Throws, if it can't find the key or the type doesn't match.*/
    /// - Parameters:
    ///   - key: a String key
    ///   - type: The expected typ to create
    ///   - root: Additional information about the context like parent element
    /// - Returns: An instance of type T OR throws an error
    func tryRead<T>(_ key : String, _ type : T.Type,root: String) throws -> T {
        if let value = self[key] as? T {
            return value
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key.description)
        }
    }
    
    
    /// eads the value list from a Mapping for a specified key and returns the provided type.

    /// - Parameters:
    ///   - key: A String
    ///   - type: The expected typ to create
    ///   - root: Additional information about the context like parent element
    /// - Returns: An instance of type V or throws if no value exists for the given key or the instance cannot be created from the dictionary value
    func tryMap<V>(_ key : String,root: String,_ result : V.Type) throws -> V  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? [String:Any] {
            let v = try V.init(value)
           return v
            
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key)
        }
    }
    
    
    
    
    
    ///  inits a list of type V which implements the KeyedElement protocol
       
    /// - Parameters:
    ///   - key: dictionary key
    ///   - root: Used to improve error output in `OpenAPIObject/UserInfo`
    ///   - result: expected type to init from the Dictionary
    /// - Returns: returns the list or throws if the key does not exist, does not point to an [AnyHashable:Any]  or the list cannot be mapped to [V]
    func tryList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : KeyedElement{
        if let list = self[key] as? [AnyHashable:Any] {
            return try MapListMap.map(list)
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key)
        }
    }
   
//    func tryOptionalAnyHashable <V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : KeyValueObjectInitializer{
//        guard let list = self[key] as? [AnyHashable:Any] else {
//            return []
//        }
//        return try MapListMap.map(list)
//    }
}

