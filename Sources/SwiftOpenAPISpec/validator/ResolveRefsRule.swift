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
// Resolve collected $ref occurrences using JSONPointerResolver.

public struct ResolveRefsRule {
    public let name = "OAS.ResolveRefs"

    public init() {}

    public func check(refs: [RefOccurrence], resolver: inout JSONPointerResolver) async -> [Diagnostic] {
        var diags: [Diagnostic] = []

        for occ in refs {
            let ref = occ.refString.trimmingCharacters(in: .whitespacesAndNewlines)
            if ref.isEmpty {
                diags.append(.init(
                    severity: .error,
                    code: .invalidRef,
                    message: "Empty $ref string.",
                    pointer: occ.pointerToDollarRef,
                    rule: name
                ))
                continue
            }

            do {
                let resolved = try await resolver.resolve(ref: ref)

                if occ.expected == .schemaObject, (resolved as? PointerNavigable) == nil {
                    diags.append(.init(
                        severity: .error,
                        code: .invalidRefTargetType,
                        message: "Resolved $ref does not point to a schema-like object.",
                        pointer: occ.pointerToDollarRef,
                        rule: name
                    ))
                }
            } catch {
                diags.append(.init(
                    severity: .error,
                    code: .invalidRef,
                    message: "Cannot resolve $ref '\(ref)': \(error)",
                    pointer: occ.pointerToDollarRef,
                    rule: name
                ))
            }
        }

        return diags
    }
}
