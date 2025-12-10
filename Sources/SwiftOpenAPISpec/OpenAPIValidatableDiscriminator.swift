//
//  OpenAPIValidatableDiscriminator.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//

public struct OpenAPIValidatableDiscriminator :  ThrowingHashMapInitiable {
    public var userInfos = [OpenAPIObject.UserInfo]()
    
    public enum DataType : String, CaseIterable {
        case integer, int32, int64, number, string
    }
    public static let PROPERTY_NAME_KEY = "propertyName"
    public static let MAPPING_KEY = "mapping"
    public static let DEFAULT_MAPPING_KEY = "defaultMapping"
    
    
    
    public init(_ map: [String : Any]) throws {
        if let propertyName = map[Self.PROPERTY_NAME_KEY] as? String {
            self.propertyName = propertyName
        }
        else {
            userInfos.append(OpenAPIObject.UserInfo(message: "propertyname in descriminator is missing, but required", infoType: .error))
        }
        if let mapping = map[Self.MAPPING_KEY] as? [String: String] {
            self.mapping = mapping
        }
        if let defaultMapping = map[Self.DEFAULT_MAPPING_KEY] as? String {
                self.defaultMapping = defaultMapping
        }
    }
    public var propertyName: String?
    public var mapping: Dictionary<String, String>?
    public var defaultMapping: String?
}
