//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct MapList<T> where T : ThrowingHashMapInitiable {
    static func map(_ list:  [Any]) throws -> [T] {
        var types = [T]()
        for element in list {
            if let elementMap = element as? [String:Any] {
                let element = try T(elementMap)
                types.append(element)
            }
        }
        return types
    }
    
}




public struct MapListMap<T> where T :  KeyedElement {
    static func map(_ elements : [AnyHashable:Any]) throws -> [T] {
        var types = [T]()
        for element in elements {
            let value = element.value
            if let key = element.key as? String,
               let valueMap = value as? [AnyHashable:Any]{
                var type = try T(valueMap)
                type.key = element.key as? String
                types.append(type)
            }
        }
        return types
    }
    
}


public protocol ThrowingHashMapInitiable {
init(_ map : [AnyHashable:Any]) throws
   
}
/**A KeyedElement expects that the key Value is set from outside**/
public protocol KeyedElement : ThrowingHashMapInitiable {
    var key : String? {get set}
}
//protocol KeyValueObjectInitializer {
//    init(_ map : [AnyHashable:Any]) throws
//}
//
