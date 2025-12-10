//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct HashmapInitializableList<T> where T : ThrowingHashMapInitiable {
    static func map(_ list:  [Any]) throws -> [T] {
        var types = [T]()
        for element in list {
            if let elementMap = element as? StringDictionary {
                let element = try T(elementMap)
                types.append(element)
            }
        }
        return types
    }
    
}




public struct KeyedElementList<T> where T :  KeyedElement {
    static func map(_ elements : StringDictionary) throws -> [T] {
        var types = [T]()
        for element in elements {
            let value = element.value
            if let valueMap = value as? StringDictionary{
                var type = try T(valueMap)
                type.key = element.key
                types.append(type)
            }
        }
        return types
    }
    
}


public protocol ThrowingHashMapInitiable {
    init(_ map : StringDictionary) throws
    var userInfos :  [OpenAPIObject.UserInfo] {get}
   
}
/**A KeyedElement expects that the key Value is set from outside**/
