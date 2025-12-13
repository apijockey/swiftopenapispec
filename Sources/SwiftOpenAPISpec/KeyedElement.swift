//
//  KeyedElement.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//

protocol PointerNavigable {
    func element(for segmentName: String) throws -> Any?
}

public protocol KeyedElement : ThrowingHashMapInitiable {
    var key : String? {get set}
   
}

public typealias StringDictionary =  [String:Any]
public extension Array where Element : KeyedElement {
    subscript (key key: String) -> Element? {
        return self.first(where: { $0.key == key })
    }
    func contains(name key: String) -> Bool {
        return self.contains(where: { $0.key == key })
    }
   func element(for segmentName: String) -> Element? {
        self.first { namedComponent in
            namedComponent.key == segmentName
        }
    }
}
extension KeyedElement {
    public static func element(for segmentName : String) throws -> Any? {
       nil
    }
}
