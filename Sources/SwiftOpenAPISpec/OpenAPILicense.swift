//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct OpenAPILicense : Codable {
    public static let NAME_KEY = "name"
    public static let IDENTIFIER_KEY = "identifier"
    public static let URL_KEY = "url"
    public init?(_ map : [String:Any?]) {
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
    public var name : String
    public var identifier : String? = nil
    public var url : String? = nil
}
