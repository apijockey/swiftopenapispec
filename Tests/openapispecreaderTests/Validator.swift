//
//  Validator.swift
//  SwiftOpenAPICLI
//
//  Created by Patric Dubois on 01.01.26.
//

import Foundation
import SwiftOpenAPISpec

public struct Validator {
    // Platzhalter-Validierung:
    // - prüft, ob openapi version existiert
    // - prüft, ob info.title und info.version vorhanden sind
    // Hier kannst du später echte Regeln ergänzen.
    public static func validate(spec: OpenAPISpecification) -> Bool {
        guard let openapi = spec.version, !openapi.isEmpty else { return false }
        guard let info = spec.info else { return false }
        guard !info.title.isEmpty, !info.version.isEmpty else { return false }
        return true
    }
}
