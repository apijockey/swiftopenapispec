/* Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
//
//  Created by Patric Dubois on 02.01.2026.
//

import Foundation

/// The validation context containing configuration and rules for OpenAPI validation.
/// 
/// This structure holds all the necessary information for validating
/// an OpenAPI document, including:
/// - The OpenAPI Specification version
/// - The validation dialect (ruleset)
/// - Base URI for reference resolution
/// - Operation IDs for reference tracking
/// - Collections of validation rules
///
/// The context is designed to be thread-safe (`Sendable`) and can be
/// shared across concurrent validation tasks.
public struct ValidationContext : Sendable {
    /// Errors that can occur when creating or using a validation context.
    enum ValidationContextError : LocalizedError {
        /// Unsupported OpenAPI version.
        /// - Parameter: The unsupported version string
        case unsupportedVersion(String)
    }
    
    /// Supported OpenAPI Specification versions.
    /// 
    /// These cases represent the different OAS versions that the validator supports.
    public enum OASVersion : Sendable{ case v30, v31, v32
        public static func fromString(_ s: String) throws -> OASVersion {
            let version = s.split(separator: ".")
            if version.count != 3 { throw ValidationContextError.unsupportedVersion(s)}
            let major = version[0]
            let minor = version[1]
            let oasversion = "v\(major)\(minor)"
            switch oasversion {
                case "v30": return .v30
                case "v31": return .v31
                case "v32": return .v32
                default: throw ValidationContextError.unsupportedVersion(s)
            }
        }
        public var dialect : ConverterConfig.Dialect {
            switch self {
            case .v30: return .oas30
            case .v31: return .jsonSchema2020_12
            case .v32: return .jsonSchema2020_12
            }
        }
    }
    
    public let version: OASVersion
    public let dialect: ConverterConfig.Dialect
    public let baseURI: String?
    
    // Optional: registrierte component names, operationIds, resolved refs, etc.
    public var operationIds: Set<String> = []
    public init(version: OASVersion, dialect: ConverterConfig.Dialect, baseURI: String?, operationIds: Set<String>) {
        self.version = version
        self.dialect = dialect
        self.baseURI = baseURI
        self.operationIds = operationIds
    }
}


