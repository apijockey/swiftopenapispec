//
//  Dictionary+extension.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//


extension Dictionary where Key == AnyHashable, Value == Any {
    /**
        throws if the key does not exist, does not point to T
     */
   
    func tryRead<T>(_ key : AnyHashable, _ type : T.Type,root: String) throws -> T {
        if let value = self[key] as? T {
            return value
        }
        else {
            throw OpenAPIObject.Errors.invalidSpecification(root, key.description)
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
            throw OpenAPIObject.Errors.invalidSpecification(root, key.description)
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
            throw OpenAPIObject.Errors.invalidSpecification(root, key)
        }
    }
    func tryOptionalList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        guard let list = self[key] as? [Any] else {
            return []
        }
        return try MapList.map(list)
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
    /// Inits an instance of Type *V* by loading the value from the current Dictionary with the given *key*
    /// - Parameters:
    ///   - key: dictionary key
    ///   - root: Used to improve error output in `OpenAPIObject/UserInfo`
    ///   - result: expected type to init from the Dictionary
    /// - Returns: an instance of type *V*, if the key exists and maps to  a Dictionary of [String:Any]
    func tryMapIfPresent<V>(_ key : String,root: String,_ result : V.Type) throws -> V?  where V : ThrowingHashMapInitiable{
        if let value = self[key] as? [String:Any] {
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
        return try MapList.map(list)
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
