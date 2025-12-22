//
//  OpenAPIExtensions.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//

public struct OpenAPIExtension : PointerNavigable  {
    public func element(for segmentName: String) throws -> Any? {
        if let simpleValue = simpleExtensionValue  {
            return simpleValue
        }
        else if let structuredExtension = structuredExtension {
            return try structuredExtension.element(for: segmentName)
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExtension", segmentName)
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public var key : String?
    public var simpleExtensionValue : String?
    public var structuredExtension : OpenAPIStructuredExtensionValues?
    
    
    public static func extensionElements(_ map : StringDictionary) throws -> [OpenAPIExtension] {
        var extensionList = [OpenAPIExtension]()
       let filteredKeys =  map.keys.filter { name in
            name.starts(with: "x-")
        }
        for (key,value) in map {
            if filteredKeys.contains(where: { filteredKey in
                key == filteredKey
            }) {
                // add
               
                if let map = value as? StringDictionary {
                    var extensionElement = OpenAPIExtension(key: key)
                    extensionElement.structuredExtension = try OpenAPIStructuredExtensionValues(map)
                    extensionList.append(extensionElement)
                }
                else if let stringValue = value as? String {
                    var extensionElement = OpenAPIExtension(key: key)
                    extensionElement.simpleExtensionValue = stringValue
                    extensionList.append(extensionElement)
                }
                else if let stringValue = value as? Int {
                    var extensionElement = OpenAPIExtension(key: key)
                    extensionElement.simpleExtensionValue = String(stringValue)
                    extensionList.append(extensionElement)
                }
                else if let stringValue = value as? Double {
                    var extensionElement = OpenAPIExtension(key: key)
                    extensionElement.simpleExtensionValue = String(stringValue)
                    extensionList.append(extensionElement)
                }
                else if let stringValue = value as? Float {
                    var extensionElement = OpenAPIExtension(key: key)
                    extensionElement.simpleExtensionValue = String(stringValue)
                    extensionList.append(extensionElement)
                }
                else if let stringValue = value as? Bool {
                    var extensionElement = OpenAPIExtension(key: key)
                    extensionElement.simpleExtensionValue = String(stringValue)
                    extensionList.append(extensionElement)
                }
               
                
            }
        }
        return extensionList
    }
}
public struct OpenAPISimpleExtensionValues : KeyedElement, PointerNavigable {
    public init(_ map: StringDictionary) throws {
        self.key = map.keys.first
        self.value = map.values.first as? String ?? ""
    }
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case "key" : return self.key
            case "value" : return self.value
            case "$ref": return self.ref
        default: throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISimpleExtensionValues", segmentName)
        }
    }
    
    
    
    public var key: String?
    public var value : String?
   
    public var ref: OpenAPISchemaReference? { nil}
    
   
}
    
public struct OpenAPIStructuredExtensionValues : ThrowingHashMapInitiable, PointerNavigable{
    public func element(for segmentName: String) throws -> Any? {
        if let properties = self.properties {
            return properties[segmentName]
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OOpenAPIStructuredExtensionValues", segmentName)
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
  
        
    public init(_ map: StringDictionary) throws {
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
