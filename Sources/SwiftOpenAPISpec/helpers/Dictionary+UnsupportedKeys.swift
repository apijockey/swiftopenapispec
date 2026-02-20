//
//  Dictionary+UnsupportedKeys.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 16.02.26.
//


extension StringDictionary {
    func diagnoseUnsupportedElements(supportedKeys : Set<String>, pointer : String) -> [Diagnostic] {
        var diagnostics: [Diagnostic] = []
        for key in self.keys where !supportedKeys.contains(key) {
                diagnostics.append(.init(severity: .error,
                                         code: .invalidElement,
                                     message: "The element '\(key)' is not supported by this version of the spec.",
                                     pointer: "/\(pointer)", rule: "OAS.UnsupportedElement"))
        }
        return diagnostics
    }
}
