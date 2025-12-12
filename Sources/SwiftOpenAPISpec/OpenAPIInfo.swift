//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct OpenAPIInfo : ThrowingHashMapInitiable {
    static let CONTACT_KEY = "contact"
    static let DESCRIPTION_KEY = "description"
    static let LICENSE_KEY = "license"
    static let SUMMARY_KEY = "summary"
    static let TERMS_KEY = "termsOfService"
    static let TITLE_KEY = "title"
    static let VERSION_KEY = "version"
    public init(_ map: [String : Any]) throws {
        guard let titleString = map[Self.TITLE_KEY] as? String ,
        let versionString = map[Self.VERSION_KEY] as? String else {
            throw OpenAPIObject.Errors.invalidSpecification("info", Self.TITLE_KEY)
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
        if let contactMap  =  map[Self.CONTACT_KEY] as? StringDictionary{
           let contact = try OpenAPIContact(contactMap)
            self.contact = contact
        }
        if let licenseMap  =  map[Self.LICENSE_KEY] as? StringDictionary,
           let license = OpenAPILicense(licenseMap) {
            self.license = license
        }
        extensions = try OpenAPIExtension.extensionElements(map)
        
    }
    public var contact : OpenAPIContact? = nil
    public var description : String? = nil
    public var extensions : [OpenAPIExtension]?
    public var license : OpenAPILicense? = nil
    public var termsOfService : String? = nil
    public var title : String
    public var  summary : String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var version : String
    
}
