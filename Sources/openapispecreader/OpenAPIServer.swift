//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
struct OpenAPIServer : ThrowingHashMapInitiable {
    static let URL_KEY = "url"
    static let DESCRIPTION_KEY = "description"
    static let VARIABLES_KEY = "variables"
   
    init(url:String){
        self.url = url
    }
    init(_ map : [AnyHashable:Any]) throws {
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
    var url : String = "/"
    var description : String? = nil
    var variables : [OpenAPIVariable] = []
    
    
}
