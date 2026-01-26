/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
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

/*
 * Copyright 2025 
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
//  Dictionary+extension.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//


extension StringDictionary {
    
    func readListIfPresent<V>(_ key : String, valueType : V.Type) -> [V]? {
        if case let .array(arrayValue) = self[key],
                let typedArray = arrayValue as? [V]{
            return typedArray
        }
        else {
            return nil
        }
    }
    func readIfPresent<V>(_ key : String, objectType : V.Type) throws -> V?  where V: ThrowingHashMapInitiable{
        if case let  .object(map) = self[key]  {
            return try V.initialize(map).value
        }
        else {
            return nil
        }
    }
    func readIfPresent<V>(_ key : String, valueType : V.Type) -> V? {
        if let  value = self[key] as? V {
            return value
        }
        else {
            return nil
        }
    }
   
    func mapListIfPresent<T>(_ key : String, objectType : T.Type) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        if case let .object(objectMap)  = self[key]  {
            for element in objectMap {
                let value = element.value
                if case let .object(valueMap) = value {
                    var type = try T.initialize( valueMap).value
                    type.key = key
                    elements.append(type)
                }
            }
        }
        return elements
    }
    func mapListIfPresent<T>(_ key : String, valueType : T.Type) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        guard case let .array(list)  = self[key],
              let typeList = list as? [T]  else {
            throw OpenAPISpecification.Errors.invalidType("")
        }
            for element in typeList {
                elements.append(element)
            }
        return elements
    }
    
    func mapListIfPresent<T>(objectType : T.Type) throws -> [T]  where  T : KeyedElement{
        var openAPIOperations = [T]()

            for element in self {
                let value = element.value
                if case let .object(valueMap) = value {
                    var type = try T.initialize( valueMap).value
                    type.key = element.key
                    openAPIOperations.append(type)
                }
            }
        
        return openAPIOperations
    }
}

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
            throw OpenAPISpecification.Errors.invalidSpecification(root, key.description)
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
            return try V.initialize( value).value
        }
        else {
            throw OpenAPISpecification.Errors.invalidSpecification(root, key.description)
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
            return try V.initialize( mapValue).value
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
            return try V.initialize( value).value
        }
        else {
            return nil
        }
    }

    func tryOptionalList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
        guard let list = self[key] as? [Any] else {
            return []
        }
        return try HashmapInitializableList.map(list).value
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
        return try HashmapInitializableList.map(list).value
    }
    
    /// Reads a dictionary value and transforms it to the specified type.
    /// - Parameters:
    ///   - key: A String
    ///   - type: The expected typ to create
    ///   - root: Additional information about the context like parent element
    /// - Returns:  An instance of type T or ni, the value does not exist or does not evaluate to type *T*
//    func tryReadIfPresent<T>(_ key : String, _ type : T.Type,root: String) -> T? {
//        if let value = self[key] as? T {
//            return value
//        }
//        else {
//            return nil
//        }
//    }
    
    /// Inits an instance of Type *V* by loading the value from the current Dictionary with the given *key*
    /// - Parameters:
    ///   - key: dictionary key
    ///   - root: Used to improve error output in `OpenAPISpecification/UserInfo`
    ///   - result: expected type to init from the Dictionary
    /// - Returns: an instance of type *V*, if the key exists and maps to  a Dictionary of StringDictionary
//    func tryMapIfPresent<V>(_ key : String,root: String,_ result : V.Type) throws -> V?  where V : ThrowingHashMapInitiable{
//        if let value = self[key] as? StringDictionary {
//            let v = try V.initialize( value)
//           return v
//            
//        }
//        else {
//            return nil
//        }
//    }
    
   
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
