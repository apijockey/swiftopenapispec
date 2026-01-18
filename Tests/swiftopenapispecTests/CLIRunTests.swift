/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
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
//  Created by Patric Dubois on 01.01.26.
//

import Foundation
import Testing
@testable import SwiftOpenAPICLI

// Das CLI-Target ist ein Executable. Wir testen die Run-Logik direkt, darum importieren wir es nicht als Modul,
// sondern verwenden seine öffentliche API, die im gleichen Package sichtbar ist.
@Suite("SwiftOpenAPICLI Run() tests")
struct CLIRunTests {

    private func fixtureURL(_ resource: String, ext: String = "yaml", subdirectory: String? = nil) throws -> URL {
        let name = "\(resource).\(ext)"
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subdirectory) else {
            throw NSError(domain: "CLIRunTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(name)"])
        }
        return url
    }

    @Test("CLI prints version and title for a valid spec")
    func testCLIWithValidSpec() async throws {
        let url = try fixtureURL("openapi", ext: "yaml", subdirectory: "Resources/3_1/valid")
        var out: (any TextOutputStream) = StringTextOutputStream()
        var err: (any TextOutputStream) = StringTextOutputStream()
        let app = SwiftOpenAPICLIApp()
        let code = await app.run(args: ["SwiftOpenAPICLI", url.path], stdout: &out, stderr: &err)

        #expect(code == 0, "CLI should exit with 0")
        let errString = try #require((err as? StringTextOutputStream)?.string)
        let outString = try #require((out as? StringTextOutputStream)?.string)
        #expect(errString.isEmpty, "stderr should be empty")
        // Grobe Plausibilitätschecks
        #expect(outString.contains("OpenAPI:"))
        #expect(outString.contains("Title:"))
    }

    @Test("CLI returns error on missing argument")
    func testCLIMissingArgument() async throws {
        var out: (any TextOutputStream) = StringTextOutputStream()
        var err: (any TextOutputStream) = StringTextOutputStream()
        let app = SwiftOpenAPICLIApp()
        let code = await app.run(args: ["SwiftOpenAPICLI"], stdout: &out, stderr: &err)

        #expect(code != 0)
        let string = try #require((err as? StringTextOutputStream)?.string)
        #expect(string.contains("Usage: SwiftOpenAPICLI"))
    }

    @Test("CLI --version prints semantic version")
    func testCLIVersionFlag() async throws {
        // Für --version wird laut Spezifikation ein Dateiname als 1. Argument erwartet,
        // auch wenn er inhaltlich nicht verwendet wird.
        let dummyPath = "/tmp/dummy.yaml"
        var out: (any TextOutputStream) = StringTextOutputStream()
        var err: (any TextOutputStream) = StringTextOutputStream()
        let app = SwiftOpenAPICLIApp()
        let code = await app.run(args: ["SwiftOpenAPICLI", dummyPath, "--version"], stdout: &out, stderr: &err)

        #expect(code == 0)
        let errString = try #require((err as? StringTextOutputStream)?.string)
        let outString = try #require((out as? StringTextOutputStream)?.string)
        #expect(errString.isEmpty)
        // Erwartet die exakt konfigurierte Version
        #expect(outString.trimmingCharacters(in: .whitespacesAndNewlines) == SwiftOpenAPICLIVersion)
    }

    @Test("CLI --validate returns OK for a valid spec")
    func testCLIValidateOK() async throws {
        let url = try fixtureURL("openapi", ext: "yaml", subdirectory: "Resources/3_1/valid")
        var out: (any TextOutputStream) = StringTextOutputStream()
        var err: (any TextOutputStream) = StringTextOutputStream()
        let app = SwiftOpenAPICLIApp()
        let code = await app.run(args: ["SwiftOpenAPICLI", url.path, "--validate"], stdout: &out, stderr: &err)

        #expect(code == 0)
        let errString = try #require((err as? StringTextOutputStream)?.string)
        let outString = try #require((out as? StringTextOutputStream)?.string)
        #expect(errString.isEmpty)
        #expect(outString.contains("Validation: OK"))
    }

    @Test("CLI with invalid option returns error")
    func testCLIInvalidOption() async throws {
        let url = try fixtureURL("openapi", ext: "yaml", subdirectory: "Resources/3_1/valid")
        var out: (any TextOutputStream) = StringTextOutputStream()
        var err: (any TextOutputStream) = StringTextOutputStream()
        let app = SwiftOpenAPICLIApp()
        let code = await app.run(args: ["SwiftOpenAPICLI", url.path, "--unknown"], stdout: &out, stderr: &err)

        #expect(code != 0)
        let errString = try #require((err as? StringTextOutputStream)?.string)
        #expect(errString.contains("Invalid option"))
    }
}

/// Einfacher String-basierter TextOutputStream zum Abgreifen von Ausgaben.
struct StringTextOutputStream: TextOutputStream {
    var string = ""
    mutating func write(_ s: String) { string.append(s) }
}
