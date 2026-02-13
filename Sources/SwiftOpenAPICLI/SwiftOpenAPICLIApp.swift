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

import Foundation
import SwiftOpenAPISpec
import Yams


/// The main logic of the SwiftOpenAPI CLI.
/// 
/// This structure implements the core functionality of the CLI and is responsible for:
/// - Parsing command line arguments
/// - Loading and processing OpenAPI specifications
/// - Validating OpenAPI documents
/// - Outputting information and error messages
///
/// The structure is designed to be testable and returns exit codes:
/// - `0` for success
/// - `1` for errors
///
/// - Example:
/// ```swift
/// let app = SwiftOpenAPICLIApp()
/// var stdout = FileHandleTextOutputStream(.standardOutput)
/// var stderr = FileHandleTextOutputStream(.standardError)
/// let exitCode = await app.run(args: ["cli", "path/to/spec.yaml"], stdout: &stdout, stderr: &stderr)
/// ```
public struct SwiftOpenAPICLIApp {
    /// Initializes a new instance of the CLI.
    /// 
    /// - Returns: A new instance of `SwiftOpenAPICLIApp`
    public init() {}

    /// Runs the CLI with the specified arguments.
    /// 
    /// - Parameters:
    ///   - args: The command line arguments
    ///   - stdout: The TextOutputStream for standard output
    ///   - stderr: The TextOutputStream for error output
    /// - Returns: The return code (0 for success, 1 for error)
    /// 
    /// This method implements the main logic of the CLI:
    /// 1. Parse the arguments
    /// 2. Load the OpenAPI specification
    /// 3. Execute the desired operation (standard output or validation)
    /// 4. Error handling
    @discardableResult
    public func run(args: [String], stdout: inout TextOutputStream, stderr: inout TextOutputStream) async -> Int {
        do {
            // args[0] = Executable-Name
            guard args.count >= 2 else {
                throw SwiftOpenAPICLIError.missingArgument
            }
            let path = args[1]
            let option: String? = args.count >= 3 ? args[2] : nil

            // --version: gibt nur die CLI-Version aus und beendet sich
            if option == "--version" {
                stdout.write("\(SwiftOpenAPICLIVersion)\n")
                return 0
            }

            // Erzeuge URL aus Pfad (lokal)
            let url: URL
            if path.hasPrefix("file://"), let u = URL(string: path) {
                url = u
            } else {
                url = URL(fileURLWithPath: path)
            }

            // Verifiziere Existenz
            if !FileManager.default.fileExists(atPath: url.path) {
                throw SwiftOpenAPICLIError.fileNotFound(path)
            }

            // Spezifikation laden
            let spec = try await OpenAPISpecification.read(url: url, documentLoader: YamsDocumentLoader())

            // --validate: einfache Validierung
            if let opt = option {
                switch opt {
                case "--validate":
                    let version = try ValidationContext.OASVersion.fromString(spec.version ?? "")
                    
                    let ctx = ValidationContext(version: version , dialect: version.dialect, baseURI: url.absoluteString, operationIds: [])
                    let objectLoader = YamsDocumentLoader()
                    
                    var resolver = JSONPointerResolver(baseURL : url,loadDocument: objectLoader.load(from:))
                    var diagnostics = try await Validator.validate(spec: spec, baseURI: url.absoluteString, ctx :  ctx, resolver: &resolver)
                    try await diagnostics.append(contentsOf: Validator.validateSchema(spec: spec, ctx: ctx, baseURI: url.absoluteString, resolver: &resolver))
                    if diagnostics.isEmpty {
                        stdout.write("Validation: OK\n")
                        return 0
                    } else {
                        stdout.write(diagnostics.description)
                        return 1
                    }
                case "--version":
                    // bereits oben behandelt; hier nur Vollständigkeit
                    stdout.write("\(SwiftOpenAPICLIVersion)\n")
                    return 0
                default:
                    throw SwiftOpenAPICLIError.invalidOption(opt)
                }
            }

            // Default-Ausgabe (wie bisher), wenn kein zweites Argument übergeben wurde
            let version = spec.version ?? "(unknown)"
            let title = spec.info?.title ?? "(no title)"
            var out = ""
            out += "OpenAPI: \(version)\n"
            out += "Title: \(title)\n"
            stdout.write(out)

            return 0
        } catch {
            stderr.write("Error: \(error.localizedDescription)\n")
            return 1
        }
    }
}
