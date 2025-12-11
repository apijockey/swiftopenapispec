//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//


import Foundation


public struct OpenAPIServer : ThrowingHashMapInitiable {
    public static let URL_KEY = "url"
    public static let NAME_KEY = "name"
    public static let DESCRIPTION_KEY = "description"
    public static let VARIABLES_KEY = "variables"
   
    public init(url:String){
        self.url = url
    }
    public init(_ map: StringDictionary) throws {
        self.url = try map.tryRead(Self.URL_KEY, String.self, root: "OpenAPIServer")
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.name = map.readIfPresent(Self.NAME_KEY, String.self)
        if let variables = map[Self.VARIABLES_KEY] as? StringDictionary {
            self.variables = try KeyedElementList.map(variables)
        }
        extensions = try OpenAPIExtension.extensionElements(map)
    }
    public var url : String = "/"
    public var name : String? = nil
    public var description : String? = nil
    //https://spec.openapis.org/oas/latest.html#server-variable-object
    public var variables : [OpenAPIVariable] = []
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var extensions : [OpenAPIExtension]?
     
    
}
public extension Array where Element == OpenAPIServer {
    subscript (url urlString : String) -> OpenAPIServer? {
        return self.first { server in
            server.url == urlString
        }
    }
}
