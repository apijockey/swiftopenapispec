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
//  Created by Patric Dubois on 10.12.25.
//


public enum ExtensionType : Sendable {
   
}
public struct OpenAPIExtension : KeyedElement, PointerNavigable, Equatable, Hashable  {
  
   
    
    public init(key : String, value : JSONValue) {
        self.key = key
        self.value = value
    }
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        fatalError("Not yet implemented init for OpenAPIExtension")
    }
    public func element(for segmentName: String) throws -> NavigationResult {
        switch value {
        case .object(let dictionary):
            if let element = dictionary.first (where: { (key,value) in
                key == segmentName
            })?.value {
                return .value(element)
            }
        case .array(let array):
            let jsonArray = try  JSONValue(array)
            return .value(jsonArray)
        case .string(let string):
            return .value(JSONValue(string: string))
        case .number(let double):
            return .value(JSONValue(double: double))
        case .integer(let int):
            return .value(JSONValue(int: int))
        case .boolean(let bool):
            return .value(JSONValue(bool:bool))
        case .null:
            return .notFound("null")
        case nil:
            return .notFound("nil")
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExtension", segmentName)
    }
    
    
    
    public var key : String?
    public var value :JSONValue?
   
    
    
    public static func extensionElements(_ map : StringDictionary, _ diagnostics :  inout [Diagnostic], pointer : String) throws -> [OpenAPIExtension] {
        var extensionList = [OpenAPIExtension]()
        let filteredKeys =  map.keys.filter { name in
            name.starts(with: "x-")
        }
        //TODO:
        for (key,value) in map {
            if filteredKeys.contains(where: { filteredKey in
                key == filteredKey
            }) {
                switch value {
                case .boolean , .integer, .number, .string:
                    let extensionElement = OpenAPIExtension(key: key, value: value)
                    extensionList.append(extensionElement)
                case .object, .array:
                    let extensionElement = OpenAPIExtension(key: key, value: value)
                    
                    extensionList.append(extensionElement)
                case .null:
                    diagnostics.append(Diagnostic(severity: .warning, code: .invalidValue, message: "null not supported for extension: '\(key)'", pointer: JSONPointer.join(pointer, key), rule: "OAS.INIT"))
                }
                
                
                
            }
            
        }
        return extensionList
    }
}
//public struct OpenAPISimpleExtensionValues : KeyedElement, PointerNavigable {
//    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
//        self.key = map.keys.first
//        self.value = map.values.first
//    }
//    public func element(for segmentName: String) throws -> NavigationResult{
//        switch segmentName {
//        case "key" : return .value(JSONValue(self.key))
//            case "value" :
//
//            return .value(self.value)
//       
//        default: throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISimpleExtensionValues", segmentName)
//        }
//    }
//    
//   
//
//    
//    public var key: String?
//    public var value : JSONValue?
//   
//   
//    
//   
//}
    
//public struct OpenAPIStructuredExtensionValues : ThrowingHashMapInitiable, PointerNavigable{
//    public func element(for segmentName: String) throws ->NavigationResult {
//        if let properties = self.properties {
//            return .value(JSONValue(properties[segmentName]))
//        }
//        throw OpenAPISpecification.Errors.unsupportedSegment("OOpenAPIStructuredExtensionValues", segmentName)
//    }
//    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
//        self.properties = map.mapValues({ value in
//            if case let .string(stringValue) = value  {
//                return stringValue
//            }
//                // Replace invalid Any extension usage with free function
//                return stringValue(from: value as Any)
//           
//        })
//        
//    }
//    public var properties : [String:String]?
//    
//   
//   
//}
public extension Array where Element == OpenAPIExtension {
    subscript(extensionName name : String) -> OpenAPIExtension? {
        return self.first(where: { element in
            element.key == name
        })
    }
}
