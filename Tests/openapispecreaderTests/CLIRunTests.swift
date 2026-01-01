//
//  CLIRunTests.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 01.01.26.
//


import Foundation
import Testing
@testable import SwiftOpenAPICLI
// Das CLI-Target ist ein Executable. Wir testen die Run-Logik direkt, darum importieren wir es nicht als Modul,
// sondern verwenden seine öffentliche API, die im gleichen Package sichtbar ist.
@Suite("SwiftOpenAPICLI Run() tests")
struct CLIRunTests {

    private func fixtureURL(_ resource: String, ext: String = "yaml") throws -> URL {
        let name = "\(resource).\(ext)"
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else {
            throw NSError(domain: "CLIRunTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(name)"])
        }
        return url
    }

    @Test("CLI prints version and title for a valid spec")
    func testCLIWithValidSpec() async throws {
        let url = try fixtureURL("openapi", ext: "yaml")
        var out : (any TextOutputStream) = StringTextOutputStream()
        var err : (any TextOutputStream)  = StringTextOutputStream()
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
        var out : (any TextOutputStream)  = StringTextOutputStream()
        var err : (any TextOutputStream) = StringTextOutputStream()
        let app = SwiftOpenAPICLIApp()
        let code = await app.run(args: ["SwiftOpenAPICLI"], stdout: &out, stderr: &err)

        #expect(code != 0)
        let string = try #require((err as? StringTextOutputStream)?.string)
        #expect(string.contains("Usage: SwiftOpenAPICLI"))
    }
}

/// Einfacher String-basierter TextOutputStream zum Abgreifen von Ausgaben.
struct StringTextOutputStream: TextOutputStream {
    var string = ""
    mutating func write(_ s: String) { string.append(s) }
}
