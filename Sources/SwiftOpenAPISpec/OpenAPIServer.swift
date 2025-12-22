//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//


import Foundation


public struct OpenAPIServer : ThrowingHashMapInitiable , PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case Self.DESCRIPTION_KEY : return self.description
            case Self.URL_KEY : return url
            case Self.NAME_KEY :return name
            case Self.VARIABLES_KEY : return variables
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIInfo", segmentName)

        }
        
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public static let DESCRIPTION_KEY = "description"
    public static let URL_KEY = "url"
    public static let NAME_KEY = "name"
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
    public var description : String? = nil
    public var extensions : [OpenAPIExtension]?
    public var name : String? = nil
    public var url : String = "/"
   
    //https://spec.openapis.org/oas/latest.html#server-variable-object
    public var variables : [OpenAPIVariable] = []
    
    
     
    
}
public extension Array where Element == OpenAPIServer {
    subscript (url urlString : String) -> OpenAPIServer? {
        return self.first { server in
            server.url == urlString
        }
    }
}
