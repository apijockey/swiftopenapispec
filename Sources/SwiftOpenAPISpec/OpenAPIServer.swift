//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//


//
//  File.swift
//
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct OpenAPIServer : ThrowingHashMapInitiable {
    public static let URL_KEY = "url"
    public static let DESCRIPTION_KEY = "description"
    public static let VARIABLES_KEY = "variables"
   
    public init(url:String){
        self.url = url
    }
    public init(_ map : [AnyHashable:Any]) throws {
        if let text = map[Self.URL_KEY] as? String{
            self.url = text
        }
        if let text = map[Self.DESCRIPTION_KEY] as? String{
            self.description = text
        }
        if let variables = map[Self.VARIABLES_KEY] as? [AnyHashable:Any] {
            self.variables = try MapListMap.map(variables)
        }
    }
    public var url : String = "/"
    public var description : String? = nil
    public var variables : [OpenAPIVariable] = []
    public var userInfos =  [OpenAPISpec.UserInfo]()
    
    
}
public extension Array where Element == OpenAPIServer {
    subscript (url urlString : String) -> OpenAPIServer? {
        return self.first { server in
            server.url == urlString
        }
    }
}
