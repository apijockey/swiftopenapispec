//
//  Dictionary+extension.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//


extension Dictionary where Key == String, Value == Any {
    
    /**
       creates an instance of type V if the dictionary value for *key* corresponds to a type that can be initiated by the value. Use, if the dictionary key is mandatory and the value must not be null
     - Parameters:
        - key: the key to use in the dictionary
        - type: The expected typ to create
        - root: Additional information about the context like parent element
     - Returns: An instance of type V or throws if no value exists for the given key or the instance cannot be created from the dictionary value
     */
    func tryRead<V>(_ key : String, _ type : V.Type,root: String) throws -> V {
        if let value = self[key] as? V {
            return value
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key.description)
        }
    }
    
    ///  Expects an existing key and tries to map to the custom type provided in result throws otherwise
    /// - Parameters:
    /// - key: the key to use in the dictionary
    /// - type: The expected typ to create
    /// - root: Additional information about the context like parent element
    /// - Returns: An Instance of type V, which implements `ThrowingHashMapInitiable` or throws if the value is not a `StringDictionary` or inita
    func tryMap<V>(_ key : String ,root: String,_ result : V.Type) throws -> V  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? StringDictionary {
            return try V.init(value)
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key.description)
        }
    }
    /**
     creates an instance of type V if the dictionary value for *key* corresponds to.
     
     Use, if the dictionary key is not mandatory or  the value may be be null
     - Parameters:
     - key: the key to use in the dictionary
     - type: The expected typ to create
     - Returns: An instance of type V  or nil
     */
    func readIfPresent<V>(_ key : String, _ type : V.Type) -> V? {
        if let value = self[key] as? V {
            return value
        }
        else {
            return nil
        }
    }
    /**
     creates an instance of type V if the dictionary value for *key* corresponds to.
     
     Use, if the dictionary key is not mandatory or  the value may be be null
     - Parameters:
        - key: the key to use in the dictionary
        - type: The expected type to create
     - Returns: An instance of type V  or nil
     */
    func mapIfPresent<V>(_ key : String, _ type : V.Type) throws -> V?  where V: ThrowingHashMapInitiable{
        if let mapValue = readIfPresent(key, StringDictionary.self){
            return try V.init(mapValue)
        }
        else {
            return nil
        }
    }
    
   
    
    ///  tries to find the key  and tries to map to the custom type provided in result
    ///
    /// throws if key is found and dictionary cannot be transformed to result custom type
    /// - Parameters:
    ///  - key: the key to use in the dictionary
    ///   - result: the expected type to create
    /// - Returns:  An instance of type V  if the value is not nil, throws if V.init(value) throws and error
    func MapIfPresent<V>(_ key : String ,_ result : V.Type) throws -> V?  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? StringDictionary {
            return try V.init(value)
        }
        else {
            return nil
        }
    }
    ///creates a list of  type V instance if the dictionary value for *key* is of type `StringDictionary`
    ///
    ///Use, if the dictionary key is not mandatory or  the value may be be null
    ///
    /// - Parameters:
    ///   - key: dictionary key
    ///   - root: Used to improve error output in `OpenAPIObject/UserInfo`
    ///   - result: expected type to init from the Dictionary
    /// - Returns: returns the list or throws if the key does not exist, does not point to an [AnyHashable:Any]  or the list cannot be mapped to [V]
    func tryList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : KeyedElement{
        if let list = self[key] as? StringDictionary {
            return try KeyedElementList.map(list)
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key)
        }
    }
    
    func tryList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        if let list = self[key] as? [Any] {
            return try HashmapInitializableList.map(list)
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key)
        }
    }
    func tryOptionalList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        guard let list = self[key] as? [Any] else {
            return []
        }
        return try HashmapInitializableList.map(list)
    }
    /// Reads a dictionary value and transforms it to the specified type.
    /// - Parameters:
    ///   - key: A String
    ///   - type: The expected typ to create
    ///   - root: Additional information about the context like parent element
    /// - Returns:  An instance of type T or ni, the value does not exist or does not evaluate to type *T*
    func tryReadIfPresent<T>(_ key : String, _ type : T.Type,root: String) -> T? {
        if let value = self[key] as? T {
            return value
        }
        else {
            return nil
        }
    }
    func mapListIfPresent<T>(_ key : String) throws -> [T]  where  T : KeyedElement{
        var openAPIOperations = [T]()
        if let map = self[key] as? StringDictionary {
            for element in map {
                let value = element.value
                if let valueMap = value as? StringDictionary{
                    var type = try T(valueMap)
                    type.key = key
                    openAPIOperations.append(type)
                }
            }
        }
        return openAPIOperations
    }
    /// Inits an instance of Type *V* by loading the value from the current Dictionary with the given *key*
    /// - Parameters:
    ///   - key: dictionary key
    ///   - root: Used to improve error output in `OpenAPIObject/UserInfo`
    ///   - result: expected type to init from the Dictionary
    /// - Returns: an instance of type *V*, if the key exists and maps to  a Dictionary of StringDictionary
    func tryMapIfPresent<V>(_ key : String,root: String,_ result : V.Type) throws -> V?  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? StringDictionary {
            let v = try V.init(value)
           return v
            
        }
        else {
            return nil
        }
    }
    
    /**
        Reads an optional sequence for give key and maps the contents to the given type
          Returns an empty list, if the key cannot be found or the key does not point to an [Any]
        Throws if the list cannot be mapped to [V]
     */
    func tryListIfPresent<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        guard let list = self[key] as? [Any] else {
            return []
        }
        return try HashmapInitializableList.map(list)
    }
//    func tryMap<V>(_ key : AnyHashable ,root: String,_ result : V.Type) throws -> V  where V : KeyValueObjectInitializer{
//        if let value = self[key] as? StringDictionary {
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
