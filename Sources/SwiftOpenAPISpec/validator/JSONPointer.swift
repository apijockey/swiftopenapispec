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
// Utilities for building stable JSON Pointers for diagnostics.

public enum JSONPointer {
    /// Escape a single JSON Pointer token per RFC 6901.
    public static func escape(_ token: String) -> String {
        token
            .replacingOccurrences(of: "~", with: "~0")
            .replacingOccurrences(of: "/", with: "~1")
    }

    /// Join a base pointer and a token.
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
