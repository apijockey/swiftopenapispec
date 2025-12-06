//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
struct OpenAPIContact : Codable {
    static let NAME_KEY = "name"
    static let URL_KEY = "url"
    static let EMAIL_KEY = "email"
    var name : String? = nil
    var url : String? = nil
    var email : String? = nil
    init?(_ map : [String:Any?]) {
        if let name = map[Self.NAME_KEY] as? String {
            self.name = name
        }
        if let url = map[Self.URL_KEY] as? String {
            self.url = url
        }
        if let email = map[Self.EMAIL_KEY] as? String {
            self.email = email
        }
    }
}
