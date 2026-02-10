//
//  UserInfo.swift
//  openapigenerator
//
//  Created by Patric Dubois on 19.12.25.
//


public struct UserInfo : Codable {
        /// user message
        public let message : String
        
        /// info type
        public let infoType : UserInfoType
    }
    /// Info type
    ///
    /// - ``OpenAPISpecification.UserInfoType.error``
    /// - ``OpenAPISpecification.UserInfoType.warning``
    /// - ``OpenAPISpecification.UserInfoType.info``
    ///
    public enum UserInfoType : String, Codable, CaseIterable {
        /// Further  processing stops
        case error
        /// Results may be inconsistent or unexpected
        case warning
        /// User handling expected but processing was sucessful
        case info
    }