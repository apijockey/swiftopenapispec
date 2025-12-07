//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct OpenAPIContact : Codable {
    public  static let NAME_KEY = "name"
    public static let URL_KEY = "url"
    public static let EMAIL_KEY = "email"
    public  var name : String? = nil
    public var url : String? = nil
    public var email : String? = nil
    public init?(_ map : [String:Any?]) {
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
