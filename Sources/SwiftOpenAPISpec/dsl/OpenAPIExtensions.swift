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


public enum extensionType {
    case simpleExtensionValue(String), structuredExtension( OpenAPIStructuredExtensionValues)
}
public struct OpenAPIExtension : KeyedElement, PointerNavigable  {
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }
    public init(load map: StringDictionary) throws {
       
    }
    public func element(for segmentName: String) throws -> NavigationResult {
        if let simpleValue = simpleExtensionValue  {
            return  .value(JSONValue(simpleValue))
        }
        else if let structuredExtension = structuredExtension {
            return try structuredExtension.element(for: segmentName)
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExtension", segmentName)
    }
    
   
    
    public var key : String?
    public var simpleExtensionValue : String?
    public var structuredExtension : OpenAPIStructuredExtensionValues?
    
    
    public static func extensionElements(_ map : StringDictionary) throws -> [OpenAPIExtension] {
        var extensionList = [OpenAPIExtension]()
       let filteredKeys =  map.keys.filter { name in
            name.starts(with: "x-")
        }
        //TODO:
        for (key,value) in map {
            if filteredKeys.contains(where: { filteredKey in
                key == filteredKey
            }) {
                // add
               
//                if let map = value as? StringDictionary {
//                    var extensionElement = OpenAPIExtension(key: key)
//                    extensionElement.structuredExtension = try OpenAPIStructuredExtensionValues(load: map)
//                    extensionList.append(extensionElement)
//                }
//                else if let stringValue = value as? String {
//                    var extensionElement = OpenAPIExtension(key: key)
//                    extensionElement.simpleExtensionValue = stringValue
//                    extensionList.append(extensionElement)
//                }
//                else if let stringValue = value as? Int {
//                    var extensionElement = OpenAPIExtension(key: key)
//                    extensionElement.simpleExtensionValue = String(stringValue)
//                    extensionList.append(extensionElement)
//                }
//                else if let stringValue = value as? Double {
//                    var extensionElement = OpenAPIExtension(key: key)
//                    extensionElement.simpleExtensionValue = String(stringValue)
//                    extensionList.append(extensionElement)
//                }
//                else if let stringValue = value as? Float {
//                    var extensionElement = OpenAPIExtension(key: key)
//                    extensionElement.simpleExtensionValue = String(stringValue)
//                    extensionList.append(extensionElement)
//                }
//                else if let stringValue = value as? Bool {
//                    var extensionElement = OpenAPIExtension(key: key)
//                    extensionElement.simpleExtensionValue = String(stringValue)
//                    extensionList.append(extensionElement)
//                }
               
                
            }
        }
        return extensionList
    }
}
public struct OpenAPISimpleExtensionValues : KeyedElement, PointerNavigable {
    public init(load map: StringDictionary) throws {
        self.key = map.keys.first
        self.value = map.values.first as? String ?? ""
    }
    public func element(for segmentName: String) throws -> NavigationResult{
        switch segmentName {
        case "key" : return .value(JSONValue(self.key))
            case "value" : return .value(JSONValue(self.value))
            case "$ref": return .value(JSONValue(self.ref))
        default: throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISimpleExtensionValues", segmentName)
        }
    }
    
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    
    public var key: String?
    public var value : String?
   
    public var ref: OpenAPISchemaReference? { nil}
    
   
}
    
public struct OpenAPIStructuredExtensionValues : ThrowingHashMapInitiable, PointerNavigable{
    public func element(for segmentName: String) throws ->NavigationResult {
        if let properties = self.properties {
            return .value(JSONValue(properties[segmentName]))
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OOpenAPIStructuredExtensionValues", segmentName)
    }
    
    
    
  
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public init(load map: StringDictionary) throws {
        self.properties = map.mapValues({ value in
            if let stringValue = value as? String {
                return stringValue
            }
                // Replace invalid Any extension usage with free function
                return stringValue(from: value as Any)
           
        })
        
    }
    public var properties : [String:String]?
    
   
   
}
public extension Array where Element == OpenAPIExtension {
    subscript(extensionName name : String) -> OpenAPIExtension? {
        return self.first(where: { element in
            element.key == name
        })
    }
}
