//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
struct OpenAPIInfo : ThrowingHashMapInitiable {
    static let TITLE_KEY = "title"
    static let VERSION_KEY = "version"
    static let SUMMARY_KEY = "summary"
    static let DESCRIPTION_KEY = "description"
    static let TERMS_KEY = "termsOfService"
    static let CONTACT_KEY = "contact"
    static let LICENSE_KEY = "license"
    let title : String
    let version : String
    var  summary : String?
    var description : String? = nil
    var termsOfService : String? = nil
    var contact : OpenAPIContact? = nil
    var license : OpenAPILicense? = nil
    public var userInfos =  [OpenAPISpec.UserInfo]()
    init(_ map : [AnyHashable:Any]) throws {
        guard let titleString = map[Self.TITLE_KEY] as? String ,
        let versionString = map[Self.VERSION_KEY] as? String else {
            throw OpenAPISpec.Errors.invalidSpecification("info", Self.TITLE_KEY)
        }
        self.title = titleString
        self.version = versionString
        if let text = map[Self.SUMMARY_KEY] as? String {
            self.summary = text
        }
        if let text = map[Self.DESCRIPTION_KEY] as? String {
            self.description = text
        }
        if let text = map[Self.TERMS_KEY] as? String {
            self.termsOfService = text
        }
        if let contactMap  =  map[Self.CONTACT_KEY] as? [String : Any?],
           let contact = OpenAPIContact(contactMap) {
            self.contact = contact
        }
        if let licenseMap  =  map[Self.LICENSE_KEY] as? [String : Any?],
           let license = OpenAPILicense(licenseMap) {
            self.license = license
        }
        
        
    }
}
