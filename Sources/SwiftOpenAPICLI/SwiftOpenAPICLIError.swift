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

import Foundation
import SwiftOpenAPISpec
import Yams

/// Errors that can be triggered by the SwiftOpenAPI CLI.
/// 
/// This enumeration defines all possible error cases that can occur
/// during the execution of the CLI.
public enum SwiftOpenAPICLIError: LocalizedError {
    /// Missing argument - the CLI was called without a path to the OpenAPI file.
    case missingArgument
    
    /// File not found - the specified OpenAPI file does not exist.
    /// - Parameter path: The path to the non-existent file
    case fileNotFound(String)
    
    /// Invalid URL or path - the specified path is not a valid file path or URL.
    /// - Parameter path: The invalid path
    case invalidURL(String)
    
    /// Error loading specification - the OpenAPI file could not be loaded.
    /// - Parameter reason: The reason for the error
    case loadFailed(String)
    
    /// Invalid option - an unknown option was provided.
    /// - Parameter option: The unknown option
    case invalidOption(String)

    /// A descriptive error message for each error case.
    public var errorDescription: String? {
        switch self {
        case .missingArgument:
            return "Usage: SwiftOpenAPICLI <path-to-openapi.(yaml|yml|json)>"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidURL(let path):
            return "Invalid URL or path: \(path)"
        case .loadFailed(let reason):
            return "Failed to load specification: \(reason)"
        case .invalidOption(let option):
            return "Invalid option: \(option)"
        }
    }
}
