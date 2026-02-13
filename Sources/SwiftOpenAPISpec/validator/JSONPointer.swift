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
/// Utilities for working with JSON Pointers (RFC 6901).
/// 
/// JSON Pointer is a standardized way to identify specific locations within
/// JSON documents. This enumeration provides helper methods for:
/// - Escaping pointer tokens according to RFC 6901
/// - Building and manipulating JSON Pointers
/// - Creating stable pointers for diagnostic messages
///
/// JSON Pointers are used extensively in the validation system to:
/// - Pinpoint the exact location of validation issues
/// - Resolve references within OpenAPI documents
/// - Navigate complex document structures
public enum JSONPointer {
    /// Escapes a single JSON Pointer token according to RFC 6901.
    /// 
    /// JSON Pointer tokens must escape certain characters:
    /// - `~` becomes `~0`
    /// - `/` becomes `~1`
    /// 
    /// - Parameter token: The token to escape
    /// - Returns: The escaped token suitable for use in JSON Pointers
    /// 
    /// - Example:
    /// ```swift
    /// JSONPointer.escape("~/users") // Returns "~0~1users"
    /// ```
    public static func escape(_ token: String) -> String {
        token
            .replacingOccurrences(of: "~", with: "~0")
            .replacingOccurrences(of: "/", with: "~1")
    }

    /// Joins a base JSON Pointer with an additional token.
    /// 
    /// This method creates a new pointer by appending a token to an existing pointer.
    /// 
    /// - Parameters:
    ///   - base: The base JSON Pointer (e.g., "/paths/~1pets")
    ///   - token: The token to append (e.g., "get")
    /// - Returns: The combined JSON Pointer (e.g., "/paths/~1pets/get")
    /// 
    /// - Example:
    /// ```swift
    /// JSONPointer.join("/paths", "~1pets") // Returns "/paths/~1pets"
    /// ```
    public static func join(_ base: String, _ token: String) -> String {
        let t = escape(token)
        return base.isEmpty ? "/\(t)" : "\(base)/\(t)"
    }
    public static func unescape(_ token: String) -> String {
        token
            .replacingOccurrences(of: "~0", with: "~")
            .replacingOccurrences(of: "~1", with: "/")
    }
}
