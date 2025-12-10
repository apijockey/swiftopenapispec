//
//  OpenAPIExtensions.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//

public struct OpenAPIExtension  {
    var key : String?
    var simpleExtensionValue : String?
    var structuredExtension : OpenAPIStructuredExtensionValues?
    
    
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
                
            }
        }
        return extensionList
    }
}
public struct OpenAPISimpleExtensionValues : KeyedElement{
    public init(_ map: StringDictionary) throws {
        self.key = map.keys.first
        self.value = map.values.first as? String ?? ""
    }
    
    
    public var userInfos: [OpenAPIObject.UserInfo] = []
    
    public var key: String?
    public var value : String?
   
    
    
   
}
    
public struct OpenAPIStructuredExtensionValues : ThrowingHashMapInitiable{
    public var userInfos =  [OpenAPIObject.UserInfo]()
        
    public init(_ map: StringDictionary) throws {
        self.properties = map.mapValues({ value in
            value as? String ?? ""
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
