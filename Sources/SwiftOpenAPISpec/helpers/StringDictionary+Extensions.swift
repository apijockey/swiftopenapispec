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
    
    
    func mapTypes<V>(value : JSONValue, valueType : V.Type, diagnostics : inout [Diagnostic], pointer : String) -> V? {
        switch valueType.self {
        case is String.Type:
            if case let .string(value) =  value,
                let stringValue = value as? V{
                return stringValue
            }
            else {
                let diagnostic = Diagnostic(severity: .error, code: .schemaViolation, message: "expected 'String' instead of '\(value.debugDescription)'", pointer: pointer , rule: "Schema.DataType")
                diagnostics.append(diagnostic)
                return nil
            }
        case is Int.Type:
            if let intValue = value.intValue as? V {
                return intValue
            }
            else {
                let diagnostic = Diagnostic(severity: .error, code: .schemaViolation, message: "expected 'Integer/Number instead of '\(value.debugDescription)'", pointer: pointer , rule: "Schema.DataType")
                diagnostics.append(diagnostic)
                return nil
            }
        case is Double.Type:
            if let doubleValue = value.doubleValue as? V {
                return doubleValue
            }
            else {
                let diagnostic = Diagnostic(severity: .error, code: .schemaViolation, message: "expected 'Double/Number' instead of '\(value.debugDescription)'", pointer: pointer , rule: "Schema.DataType")
                diagnostics.append(diagnostic)
                return nil
            }
        case is Float.Type:
            if let value = value.floatValue as? V {
                return value
            }
            else {
                let diagnostic = Diagnostic(severity: .error, code: .schemaViolation, message: "expected 'Float/Number' instead of '\(value.debugDescription)'", pointer: pointer , rule: "Schema.DataType")
                diagnostics.append(diagnostic)
                return nil
            }
        case is Bool.Type:
            if case let .boolean(value) = value,
            let boolValue = value as? V{
                return boolValue
            }
            else {
                let diagnostic = Diagnostic(severity: .error, code: .schemaViolation, message: "expected 'Boolean' instead of '\(value.debugDescription)'", pointer: pointer , rule: "Schema.DataType")
                diagnostics.append(diagnostic)
                return nil
            }
        case is JSONValue.Type:
           
            return (value as? V)
        default:
            let diagnostic = Diagnostic(severity: .warning, code: .schemaViolation, message: "unexpected value type '\(value.debugDescription)'", pointer: pointer , rule: "Schema.DataType")
            diagnostics.append(diagnostic)
            return (value as? V)
        }
    }
    func readListIfPresent<V>(_ key : String, valueType : V.Type, diagnostics : inout [Diagnostic], pointer : String) -> [V]? {
        
        var typedArray = [V]()
        if case let .array(arrayValue) = self[key] {
            for value in arrayValue {
                if let typedValue = mapTypes(value: value, valueType: valueType, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, key)) {
                    typedArray.append(typedValue)
                }
            }
            return typedArray
        }
        else {
            return nil
        }
    }
    func readIfPresent<V>(_ key : String, valueType : V.Type, diagnostics : inout [Diagnostic], pointer : String) -> V? {
        guard let value = self[key] else { return nil }
        return mapTypes(value: value, valueType: valueType, diagnostics: &diagnostics, pointer: pointer)
    }
    
    func readIfPresent<V>(_ key : String, objectType : V.Type, diagnostics : inout [Diagnostic], pointer : String) throws -> V?  where V : ThrowingHashMapInitiable{
       
        guard let value = self[key] else { return nil }
        guard case let .object(objectMap) = value else { return nil }
        return  try  V(load: objectMap,diagnostics: &diagnostics, pointer: pointer)
    }
//    func readNamedElementIfPresent<V>(_ key : String, objectType : V.Type) throws -> OpenAPINamedElement<V>?  where V : ThrowingHashMapInitiable{
//        var diagnostics: [Diagnostic] = []
//        guard let value = self[key] else { return nil }
//        guard case let .object(objectMap) = value else { return nil }
//        var namedElement = try OpenAPINamedElement<V>(load: objectMap, objectType: V.self, &diagnostics)
//        
//        return  namedElement
//    }
    
    func mapListIfPresent<T>(_ key : String, objectType : T.Type, diagnostics: inout [Diagnostic], pointer: String) throws -> [T]  where  T : ThrowingHashMapInitiable{
        var elements = [T]()
       
        if case let .object(objectMap)  = self[key]  {
            for element in objectMap {
                let value = element.value
                if case let .object(valueMap) = value {
                    let type = try T.initialize(load:  valueMap, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, element.key)).value
                    elements.append(type)
                }
            }
        }
        else if case let .array(array)  = self[key]  {
            for element in array {
                if case let .object(valueMap) = element {
                    let element = try T.initialize(load: valueMap, diagnostics: &diagnostics, pointer: pointer).value
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
    func mapDictionaryfPresent<T>(_ key : String, objectType : T.Type, diagnostics: inout [Diagnostic], pointer : String) throws -> [T]  where  T : ThrowingHashMapInitiable{
        var elements = [T]()
        
        if case let .object(objectMap)  = self[key]  {
            for element in objectMap {
                let value = element.value
                if case let .object(valueMap) = value {
                    let type = try T.initialize(load:  valueMap, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, element.key)).value
                    elements.append(type)
                }
            }
        }
        return elements
    }
    
    func mapListIfPresent<T>(_ key : String, objectType : T.Type , diagnostics: inout [Diagnostic], pointer : String) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        if let value = self[key] {
        if case let .object(objectMap)  = value,
           objectMap.count == 1 ,
           let objectValue = objectMap.first?.value,
           case let .object(map) = objectValue,
           let objectKey = objectMap.first?.key{
            
            var type = try T.initialize(load:  map, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, objectKey)).value
            if type.key == nil && objectMap.keys.count == 1{
                type.key = objectKey
            }
            elements.append(type)
       
                
           
        }
           
           
        else if case let .object(objectMap)  = value,
                objectMap.count > 1 {
            for element in objectMap {
                let value = element.value
                if case let .object(valueMap) = value {
                    
                    var type = try T.initialize(load:  valueMap, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, element.key)).value
                    if type.key == nil {
                        type.key = element.key
                    }
                    elements.append(type)
                }
                if case .string = value {
                    var type = try T.initialize(load:  [key:value], diagnostics: &diagnostics, pointer: pointer).value
                    if type.key == nil {
                        type.key = element.key
                    }
                    elements.append(type)
                    
                }
            }
        }
       
        else if case let .array(arrayList) = value {
            for (index,jsonElement) in arrayList.enumerated() {
                if case let .object(objectElement) = jsonElement {
                    var type = try T.initialize(load:  objectElement, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, String(index))).value
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
    func mapListIfPresent<T>(_ key : String, valueType : T.Type, pointer : String) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
        guard let value = self[key] else {
            return elements
        }
        if case let .object(element)  = value,
           case let .object(elementContent) = element.first?.value{
            var type = try T.initialize(load: elementContent, diagnostics: &diagnostics, pointer: pointer).value
            type.key = element.keys.first // the StringDictionary holds one key and the object information in the values
            elements.append(type)
            return elements
        }
        if case let .array(list)  = value {
            for (index,element) in list.enumerated() {
                if case let .object(objectElement) = element {
                    var type = try T.initialize(load: objectElement, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, String(index))).value
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
    func mapListIfPresent<T>(objectType : T.Type, pointer : String) throws -> [T]  where  T : ThrowingHashMapInitiable{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
            for element in self {
                let value = element.value
                if case let .object(valueMap) = value {
                    let type = try T.initialize(load: valueMap, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, element.key)).value
                    
                    elements.append(type)
                }
            }
        
        return elements
    }
    func mapListIfPresent<T>(objectType : T.Type, pointer : String) throws -> [T]  where  T : KeyedElement{
        var elements = [T]()
        var diagnostics: [Diagnostic] = []
            for element in self {
                let value = element.value
                if case let .object(valueMap) = value {
                    var type = try T.initialize(load: valueMap, diagnostics: &diagnostics, pointer : JSONPointer.join(pointer, element.key)).value
                    type.key = element.key
                    elements.append(type)
                }
                //this must be a reference
                else if case .string(let string) = value,
                        string == OpenAPISchemaReference.REF_KEY {
                        
                    var type = try T.initialize(load: self, diagnostics: &diagnostics, pointer: pointer).value
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
    
}
extension Dictionary.Values {
    func getValue(_ key: AnyHashable) {}
}

extension StringDictionary {
    mutating func addOptionalString(string: String?, forKey key: String)  {
        guard let string = string
        else { return }
        self[key] = JSONValue(string:string)
      
    }
    mutating func addOptionalInt(integer: Int?, forKey key: String)  {
        guard let integer = integer
        else { return }
        self[key] = JSONValue(int: integer)
      
    }
    mutating func addOptionalDouble(double: Double?, forKey key: String)  {
        guard let double = double
        else { return }
        self[key] = JSONValue(double: double)
      
    }
    mutating func addOptionalDouble(boolean: Bool?, forKey key: String)  {
        guard let boolean = boolean
        else { return }
        self[key] = JSONValue(bool: boolean)
      
    }
    mutating func addOptionalStringDictionary(stringDictionary: StringDictionary?, forKey key: String)  {
        guard let stringDictionary =  stringDictionary,
                !stringDictionary.isEmpty else {
            return
        }
        self[key] = JSONValue.object(stringDictionary)
    }
    
    
}
extension StringDictionary {
    func diagnoseUnsupportedElements(supportedKeys : Set<String>, pointer : String) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        for key in self.keys where !supportedKeys.contains(key) {
                diagnostics.append(.init(severity: .error,
                                         code: .invalidElement,
                                     message: "The element '\(key)' is not supported by this version of the spec.",
                                     pointer: "/\(pointer)", rule: "OAS.UnsupportedElement"))
        }
        return diagnostics
    }
}
