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
    
    
    func mapTypes<V>(value : JSONValue, valueType : V.Type) -> V? {
        switch V.self {
        case is String.Type:
            return (value.stringValue as? V)
        case is Int.Type:
            return (value.intValue as? V)
        case is Double.Type:
            return (value.doubleValue as? V)
        case is Float.Type:
            return (value.floatValue as? V)
        case is Bool.Type:
            return (value.boolValue as? V)
        case is JSONValue.Type:
            return (value as? V)
        default:
            // Fallback: try direct cast (for future types that might already be JSONValue-backed)
            return (value as? V)
        }
    }
    func readListIfPresent<V>(_ key : String, valueType : V.Type) -> [V]? {
        var typedArray = [V]()
        if case let .array(arrayValue) = self[key] {
            for value in arrayValue {
                if let typedValue = mapTypes(value: value, valueType: valueType) {
                    typedArray.append(typedValue)
                }
            }
            return typedArray
        }
        else {
            return nil
        }
    }
    func readIfPresent<V>(_ key : String, valueType : V.Type) -> V? {
        guard let value = self[key] else { return nil }
        return mapTypes(value: value, valueType: valueType)
    }
    
    func readIfPresent<V>(_ key : String, objectType : V.Type) throws -> V?  where V : ThrowingHashMapInitiable{
        var diagnostics: [Diagnostic] = []
        guard let value = self[key] else { return nil }
        guard case let .object(objectMap) = value else { return nil }
        return  try  V(load: objectMap,&diagnostics)
    }
//    func readNamedElementIfPresent<V>(_ key : String, objectType : V.Type) throws -> OpenAPINamedElement<V>?  where V : ThrowingHashMapInitiable{
//        var diagnostics: [Diagnostic] = []
//        guard let value = self[key] else { return nil }
//        guard case let .object(objectMap) = value else { return nil }
//        var namedElement = try OpenAPINamedElement<V>(load: objectMap, objectType: V.self, &diagnostics)
//        
//        return  namedElement
//    }
    
    func mapListIfPresent<T>(_ key : String, objectType : T.Type) throws -> [T]  where  T : ThrowingHashMapInitiable{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
        if case let .object(objectMap)  = self[key]  {
            for element in objectMap {
                let value = element.value
                if case let .object(valueMap) = value {
                    var type = try T.initialize(load:  valueMap, diagnostics: diagnostics).value
                    elements.append(type)
                }
            }
        }
        else if case let .array(array)  = self[key]  {
            for element in array {
                if case let .object(valueMap) = element {
                    let element = try T.initialize(load: valueMap, diagnostics: diagnostics).value
                    elements.append(element)
                }
            }
        }
        return elements
    }
    
//    func mapNamedElementListIfPresent<T>(_ key : String, objectType : T.Type) throws -> [OpenAPINamedElement<T>]  where  T : ThrowingHashMapInitiable, T : PointerNavigable{
//        // I have a list, this list may contain one element only.
//        var elements = [OpenAPINamedElement<T>]()
//        var diagnostics: [Diagnostic] = []
//        if case let .object(objectMap)  = self[key]  {
//            for element in objectMap {
//                let value = element.value
//                if case let .object(valueMap) = value {
//                    var namedElement = try OpenAPINamedElement<T>(load: valueMap, objectType: T.self, &diagnostics)
//                    namedElement.key = element.key
//                    elements.append(namedElement)
//                }
//            }
//        }
//        else if case let .array(array)  = self[key]  {
//            for element in array {
//                if case let .object(valueMap) = element {
//                    var namedElement = try OpenAPINamedElement<T>(load: valueMap, objectType: T.self, &diagnostics)
//                    namedElement.key = "Hallo"
//                    elements.append(namedElement)
//                }
//            }
//        }
//        return elements
//    }
    func mapDictionaryfPresent<T>(_ key : String, objectType : T.Type) throws -> [T]  where  T : ThrowingHashMapInitiable{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
        if case let .object(objectMap)  = self[key]  {
            for element in objectMap {
                let value = element.value
                if case let .object(valueMap) = value {
                    var type = try T.initialize(load:  valueMap, diagnostics: diagnostics).value
                    elements.append(type)
                }
            }
        }
        return elements
    }
    
    func mapListIfPresent<T>(_ key : String, objectType : T.Type) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
        if let value = self[key] {
        if case let .object(objectMap)  = value{
            for element in objectMap {
                let value = element.value
                if case let .object(valueMap) = value {
                    if element.key == "EventEnvelope" {
                        print("WAIT")
                    }
                    var type = try T.initialize(load:  valueMap, diagnostics: diagnostics).value
                    if type.key == nil {
                        type.key = element.key
                    }
                    elements.append(type)
                }
                if case .string = value {
                    var type = try T.initialize(load:  [key:value], diagnostics: diagnostics).value
                    if type.key == nil {
                        type.key = element.key
                    }
                    elements.append(type)
                    
                }
            }
        }
        if case let .array(arrayList) = value {
            for jsonElement in arrayList {
                if case let .object(objectElement) = jsonElement {
                    var type = try T.initialize(load:  objectElement, diagnostics: diagnostics).value
                    if type.key == nil {
                        type.key = objectElement.keys.first
                    }
                    elements.append(type)
                    
                    
                }
            }
        }
        }
        return elements
    }
    func mapListIfPresent<T>(_ key : String, valueType : T.Type) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
        guard let value = self[key] else {
            return elements
        }
        if case let .object(element)  = value,
           case let .object(elementContent) = element.first?.value{
            var type = try T.initialize(load: elementContent, diagnostics: diagnostics).value
            type.key = element.keys.first // the StringDictionary holds one key and the object information in the values
            elements.append(type)
            return elements
        }
        if case let .array(list)  = value {
            for element in list {
                if case let .object(objectElement) = element {
                    var type = try T.initialize(load: objectElement, diagnostics: diagnostics).value
                    if type.key == nil {
                        type.key = objectElement.keys.first
                    }
                    elements.append(type)
                }
                
            }
            return elements
        }
        return elements
    }
    func mapListIfPresent<T>(objectType : T.Type) throws -> [T]  where  T : ThrowingHashMapInitiable{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
            for element in self {
                let value = element.value
                if case let .object(valueMap) = value {
                    var type = try T.initialize(load: valueMap, diagnostics: diagnostics).value
                    
                    elements.append(type)
                }
            }
        
        return elements
    }
    func mapListIfPresent<T>(objectType : T.Type) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
            for element in self {
                let value = element.value
                if case let .object(valueMap) = value {
                    var type = try T.initialize(load: valueMap, diagnostics: diagnostics).value
                    type.key = element.key
                    elements.append(type)
                }
                //this must be a reference
                else if case .string(let string) = value,
                        string == OpenAPISchemaReference.REF_KEY {
                        let value = element.value
                        var type = try T.initialize(load: self, diagnostics: diagnostics).value
                        type.key = element.key
                        elements.append(type)
                }
            }
        
        return elements
    }
}

extension Dictionary where Key == String, Value == JSONValue {
    
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
//    func tryMap<V>(_ key : String ,root: String,_ result : V.Type) throws -> V  where V : ThrowingHashMapInitiable{
//        if let value = self[key] as? StringDictionary {
//            return try V.initialize( value).value
//        }
//        else {
//            throw OpenAPISpecification.Errors.invalidSpecification(root, key.description)
//        }
//    }
    /**
     creates an instance of type V if the dictionary value for *key* corresponds to.
     
     Use, if the dictionary key is not mandatory or  the value may be be null
     - Parameters:
     - key: the key to use in the dictionary
     - type: The expected typ to create
     - Returns: An instance of type V  or nil
     */
//    func readIfPresent<V>(_ key : String, _ type : V.Type) -> V? {
//        if let value = self[key] as? V {
//            return value
//        }
//        else {
//            return nil
//        }
//    }
    /**
     creates an instance of type V if the dictionary value for *key* corresponds to.
     
     Use, if the dictionary key is not mandatory or  the value may be be null
     - Parameters:
        - key: the key to use in the dictionary
        - type: The expected type to create
     - Returns: An instance of type V  or nil
     */
//    func mapIfPresent<V>(_ key : String, _ type : V.Type) throws -> V?  where V: ThrowingHashMapInitiable{
//       if let mapValue = readIfPresent(key, StringDictionary.self){
//            return try V.initialize( mapValue).value
//        }
//        else {
//            return nil
//        }
//    }
    
   
    
    ///  tries to find the key  and tries to map to the custom type provided in result
    ///
    /// throws if key is found and dictionary cannot be transformed to result custom type
    /// - Parameters:
    ///  - key: the key to use in the dictionary
    ///   - result: the expected type to create
    /// - Returns:  An instance of type V  if the value is not nil, throws if V.init(value) throws and error
//    func MapIfPresent<V>(_ key : String ,_ result : V.Type) throws -> V?  where V : ThrowingHashMapInitiable{
//        if let value = self[key] as? StringDictionary {
//            return try V.initialize( value).value
//        }
//        else {
//            return nil
//        }
//    }

//    func tryOptionalList<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
//        guard let list = self[key] as? [Any] else {
//            return []
//        }
//        return try HashmapInitializableList.map(list).value
//    }
//    
    
    
    /**
        Reads an optional sequence for give key and maps the contents to the given type
          Returns an empty list, if the key cannot be found or the key does not point to an [Any]
        Throws if the list cannot be mapped to [V]
//     */
//    func tryListIfPresent<V>(_ key : String,root: String,_ result : V.Type) throws -> [V]  where V : ThrowingHashMapInitiable{
//        guard let list = self[key] as? [Any] else {
//            return []
//        }
//        return try HashmapInitializableList.map(list).value
//    }
    
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
