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


/*
 public enum JSONValue: Equatable {
     case object([String: JSONValue])
     case array([JSONValue])
     case string(String)
     case number(Double)
     case integer(Int)
     case boolean(Bool)
     case null
 }
 */


public struct Diagnostic: Sendable, Equatable, CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        return formattedDescription()
    }
    
    public var description: String {
        return formattedDescription()
    }
    
    private func formattedDescription() -> String {
        // Begrenzung der Länge für rule auf 40 Zeichen
        let truncatedRule = String(rule.prefix(60))
        
        // Farbcodes basierend auf der Schwere
        let severityColor: String
        let resetColor = "\u{001B}[0m"
        
        switch severity {
        case .error:
            severityColor = "\u{001B}[31m" // Rot
        case .warning:
            severityColor = "\u{001B}[33m" // Gelb
        case .info:
            severityColor = "\u{001B}[90m" // Grau
        }
        
        // Formatierte Ausgabe mit festen Spaltenbreiten
        let severityStr = String(format: "%-12@", severity.rawValue) // 12 Zeichen breit
        let codeStr = String(format: "%-25@", code.rawValue) // 25 Zeichen breit
        let ruleStr = String(format: "%-60@", truncatedRule) // 60 Zeichen breit
        
        // Zweizeilige Ausgabe für bessere Lesbarkeit
        let line1 = String(format: "%@%@%@ %@ %@", 
                          severityColor, severityStr, resetColor,
                          codeStr, ruleStr)
        let line2 = String(format: "  %@ %@", pointer, message)
        
        return "\(line1)\n\(line2)"
    }
    
    public enum Severity : String, Sendable { case warning, error,info }
    public enum Code: String, Sendable, Equatable {
        case invalidRef
        case invalidRefTargetType
        case schemaViolation
        case missingRequired
        case missingResponses
        case invalidElement
        case invalidValue
        case invalidType
        case debugTrace
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
        let sortedDiagnostics = self.sorted {
            // Zuerst nach severity sortieren (error > warning > info)
            if $0.severity != $1.severity {
                let order0 = severityOrder($0.severity)
                let order1 = severityOrder($1.severity)
                return order0 > order1
            }
            // Dann nach pointer sortieren
            return $0.pointer < $1.pointer
        }
        return sortedDiagnostics.map(\.description).joined(separator: "\n")
    }
    
    public var debugDescription: String {
        let sortedDiagnostics = self.sorted {
            // Zuerst nach severity sortieren (error > warning > info)
            if $0.severity != $1.severity {
                let order0 = severityOrder($0.severity)
                let order1 = severityOrder($1.severity)
                return order0 > order1
            }
            // Dann nach pointer sortieren
            return $0.pointer < $1.pointer
        }
        return sortedDiagnostics.map(\.debugDescription).joined(separator: "\n")
    }
    
    private func severityOrder(_ severity: Diagnostic.Severity) -> Int {
        switch severity {
        case .error: return 3
        case .warning: return 2
        case .info: return 1
        }
    }
}
