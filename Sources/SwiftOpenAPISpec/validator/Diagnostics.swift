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

public struct RefOccurrence: Equatable {
    public enum ExpectedTarget { case schemaObject }

    public let refString: String
    /// Pointer that should end at "/$ref"
    public let pointerToDollarRef: String
    public let expected: ExpectedTarget

    public init(refString: String, pointerToDollarRef: String, expected: ExpectedTarget) {
        self.refString = refString
        self.pointerToDollarRef = pointerToDollarRef
        self.expected = expected
    }
}

public struct Diagnostic: Equatable, CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        return "severity: \(severity.rawValue), code: \(code.rawValue), message: \(message), pointer: \(pointer), rule: \(rule)"
    }
    
    public var description: String {
        return "severity: \(severity.rawValue), code: \(code.rawValue), message: \(message), pointer: \(pointer), rule: \(rule)"
    }
    
    public enum Severity : String { case warning, error }
    public enum Code: String, Equatable {
        case invalidRef
        case invalidRefTargetType
        case schemaViolation
        case missingRequired
        case missingResponses
        case invalidValue
        case invalidType
    }

    public let severity: Severity
    public let code: Code
    public let message: String
    public let pointer: String
    public let rule: String

    public init(severity: Severity, code: Code, message: String, pointer: String, rule: String) {
        self.severity = severity
        self.code = code
        self.message = message
        self.pointer = pointer
        self.rule = rule
    }
    
}

extension Array where Element == Diagnostic {
    public var description: String {
        self.map(\.description).joined(separator: "\n")
    }
    public var debugDescription: String {
        self.map(\.debugDescription).joined(separator: "\n")
    }
}
