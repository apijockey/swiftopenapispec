//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/// Helper struct which maps  a Yaml-List / JSON-Array to Swift-Array
public struct HashmapInitializableList<T> where T : ThrowingHashMapInitiable {
    
    /// Creates a list of elements from a Yaml-List / JSON-Array 
    /// - Parameter a Yaml-List / JSON-Array
    /// - Returns: a Swift Array or  throws an error if any element  of type `T` cannot be created
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



/// Helper struct which maps  a dictionary of Elements with a unique identifier like a name  to a list of values
public struct KeyedElementList<T> where T :  KeyedElement {
    
    /// Creates a list of elements with a unique `key` element from the keys in the dictinary with elements that hold  the `values`contents in its properties
    /// - Parameter elements: an ordinary Dictionary<String,Any>
    /// - Returns: a list of elements or throws an error if any element  of type `T` cannot be created
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
    static func map(list : [StringDictionary], yamlKeyName : String) throws -> [T] {
        var types = [T]()
        for listElement in list {
                var element = try T(listElement)
                if let key = listElement[yamlKeyName] as? String{
                    element.key = key
                    types.append(element)
            }
            else {
                throw OpenAPISpecification.Errors.invalidYaml("Could not find a entry in \(list.debugDescription) for \(yamlKeyName)")
            }
            
            
        }
        return types
        
    }
    
}

public protocol JSONPointerResolvable {
    func resolveSubscript(key : String) -> String?
}

public protocol ThrowingHashMapInitiable {
    init(_ map : StringDictionary) throws
    var userInfos :  [OpenAPISpecification.UserInfo] {get}
   
}
/**A KeyedElement expects that the key Value is set from outside**/

public struct RelativeReferenceResolver {
    
    var specMap : [URL:OpenAPISpecification] = [URL:OpenAPISpecification]()
    enum Errors : LocalizedError {
        case invalidURL(String)
    }
    private let baseURL : String
    private let baseSpec : OpenAPISpecification
    public static func resolve(_ url: String, baseUrl: String) throws -> URL {
        guard let baseURL = URL(string: baseUrl),
        let resolvedURL = URL(string: url, relativeTo: baseURL)else {
            throw Self.Errors.invalidURL("\(url) \(baseUrl)")
        }
        return resolvedURL
        
    }
    
    public init(baseURL: String, baseSpec: OpenAPISpecification) {
        self.baseURL = baseURL
        self.baseSpec = baseSpec
    }
    public func resolve<T>(component type  : T.Type, from reference : String) throws -> T? {
        if reference.hasPrefix("#"){
            // load from localFile
            return nil
        }
        else if reference.hasPrefix("./") {
            // load from relative file
            return nil
        }
        return nil
        
    }
    /// sehr einfache Fragment-Auflösung für "#/components/schemas/User"
        func resolveFragment(root: [String: Any], fragment: String) throws -> Any {
            let trimmed = fragment.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let keys = trimmed.split(separator: "/").map(String.init)

            var current: Any = root
            for key in keys {
                guard let dict = current as? [String: Any] else {
                    throw NSError(domain: "RefResolver", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey: "Expected dict at \(key)"])
                }
                guard let next = dict[key] else {
                    throw NSError(domain: "RefResolver", code: 2,
                                  userInfo: [NSLocalizedDescriptionKey: "Key \(key) not found"])
                }
                current = next
            }
            return current
        }
   
}
