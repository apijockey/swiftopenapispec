//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
extension Dictionary where Key == String, Value == Any {
    /** Reads a dictionary value and transforms it to the specified type. Throws, if it can't find the key or the type doesn't match.*/
    func tryRead<T>(_ key : String, _ type : T.Type,root: String) throws -> T {
        if let value = self[key] as? T {
            return value
        }
        else {
            throw OpenAPISpec.Errors.invalidSpecification(root, key.description)
        }
    }
    /**
        Reads the value list from a Mapping for a specified key and returns the provided type.
        Throws if the key does not exist, does not point to an [String:Any]  or the Dictionary cannot be mapped to V
     */
    func tryMap<V>(_ key : String,root: String,_ result : V.Type) throws -> V  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? [String:Any] {
            let v = try V.init(value)
           return v
            
        }
        else {
            throw OpenAPISpec.Errors.invalidSpecification(root, key)
        }
    }
    
    
    /**
        Reads a list of dictionaries where key and values will be held in the provided result type that
     implements the KeyedElement protocol
        throws if the key does not exist, does not point to an [AnyHashable:Any]  or the list cannot be mapped to [V]
     */
    func tryList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : KeyedElement{
        if let list = self[key] as? [AnyHashable:Any] {
            return try MapListMap.map(list)
        }
        else {
            throw OpenAPISpec.Errors.invalidSpecification(root, key)
        }
    }
    /**
        Reads an optional sequence for give key and maps the contents to the given type
          Returns an empty list, if the key cannot be found or the key does not point to an [Any]
        Throws if the list cannot be mapped to [V]
     */
    func tryOptionalList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        guard let list = self[key] as? [Any] else {
            return []            
        } 
        return try MapList.map(list)
    }
//    func tryOptionalAnyHashable <V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : KeyValueObjectInitializer{
//        guard let list = self[key] as? [AnyHashable:Any] else {
//            return []
//        }
//        return try MapListMap.map(list)
//    }
}

extension Dictionary where Key == AnyHashable, Value == Any {
    /**
        throws if the key does not exist, does not point to T
     */
   
    func tryRead<T>(_ key : AnyHashable, _ type : T.Type,root: String) throws -> T {
        if let value = self[key] as? T {
            return value
        }
        else {
            throw OpenAPISpec.Errors.invalidSpecification(root, key.description)
        }
    }
    /**
        Reads a supported built-in Type if the key exists and the type corresponds to the value
     */
    func readIfPresent<T>(_ key : AnyHashable, _ type : T.Type) -> T? {
        if let value = self[key] as? T {
            return value
        }
        else {
            return nil
        }
    }
    func mapIfPresent<T>(_ key : AnyHashable, _ type : T.Type) throws -> T?  where T: ThrowingHashMapInitiable{
        if let mapValue = readIfPresent(key, [AnyHashable:Any].self){
            return try T.init(mapValue)
        }
        else {
            return nil
        }
    }
    /**
        Expects an existing key and tries to map to the custom type provided in result
        throws otherwise
     */
    func tryMap<V>(_ key : AnyHashable ,root: String,_ result : V.Type) throws -> V  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? [String:Any] {
            return try V.init(value)
        }
        else {
            throw OpenAPISpec.Errors.invalidSpecification(root, key.description)
        }
    }
    /**
        tries to find the key  and tries to map to the custom type provided in result
         throws if key is found and dictionary cannot be transformed to result custom type
     */
    func tryMapIfPresent<V>(_ key : AnyHashable ,_ result : V.Type) throws -> V?  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? [String:Any] {
            return try V.init(value)
        }
        else {
            return nil
        }
    }
    func tryList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        if let list = self[key] as? [Any] {
            return try MapList.map(list)
        }
        else {
            throw OpenAPISpec.Errors.invalidSpecification(root, key)
        }
    }
    func tryOptionalList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        guard let list = self[key] as? [Any] else {
            return []
        }
        return try MapList.map(list)
    }
    func mapListIfPresent<T>(_ key : String) throws -> [T]  where  T : KeyedElement{
        var openAPIOperations = [T]()
        if let map = self[key] as? [AnyHashable:Any] {
            for element in map {
                let value = element.value
                if let key = element.key as? String,
                   let valueMap = value as? [AnyHashable:Any]{
                    var type = try T(valueMap)
                    type.key = key
                    openAPIOperations.append(type)
                }
            }
        }
        return openAPIOperations
    }
//    func tryMap<V>(_ key : AnyHashable ,root: String,_ result : V.Type) throws -> V  where V : KeyValueObjectInitializer{
//        if let value = self[key] as? [String:Any] {
//            return try V.init(value)
//        }
//        else {
//            throw OpenAPISpec.Errors.invalidSpecification(root, key.description)
//        }
//    }
//    func tryOptionalAnyHashable <V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : KeyValueObjectInitializer{
//        guard let list = self[key] as? [AnyHashable:Any] else {
//            return []
//        }
//        return try MapListMap.map(list)
//    }
}
extension Dictionary.Values {
    func getValue(_ key: AnyHashable) {}
}
