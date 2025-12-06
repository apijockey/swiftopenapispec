//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
struct OpenAPILicense : Codable {
    static let NAME_KEY = "name"
    static let IDENTIFIER_KEY = "identifier"
    static let URL_KEY = "url"
    init?(_ map : [String:Any?]) {
        guard let name = map[Self.NAME_KEY] as? String else {
            return nil
        }
        self.name = name
        if let text =  map[Self.IDENTIFIER_KEY] as? String {
            self.identifier = text
        }
        if let url = map[Self.URL_KEY] as? String {
            self.url = url
        }
        if let identifier = map[Self.URL_KEY] as? String {
            self.identifier = identifier
        }
    }
    let name : String
    var identifier : String? = nil
    var url : String? = nil
}
