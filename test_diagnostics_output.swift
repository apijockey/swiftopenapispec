#!/usr/bin/swift

import Foundation
import SwiftOpenAPISpec

// Test der Diagnostic-Ausgabe
let diagnostic = Diagnostic(
    severity: .error,
    code: .missingRequired,
    message: "OAS.Required",
    pointer: "/paths/get",
    rule: "missingRequired"
)

print("Diagnostic Output:")
print(diagnostic.description)
print("\nExpected format:")
print("SEVERITY   CODE                     RULE                                    POINTER    MESSAGE")
print("---------- ------------------------- -------------------------------------------- ---------- -------")
