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
import Foundation

/// The main entry point of the SwiftOpenAPI CLI.
/// 
/// This structure implements the `@main` attribute and is responsible for:
/// - Initializing standard input/output streams
/// - Calling the main CLI logic
/// - Handling the return code
///
@main
struct Main {
    /// The main method called when the CLI starts.
    /// 
    /// - Parameter: None (automatically called by Swift)
    /// 
    /// 
    /// This method:
    /// 1. Initializes standard input/output streams
    /// 2. Calls the main CLI logic
    /// 3. Ends the program with the appropriate return code
    static func main() async {
        var standardOut : (any TextOutputStream) = FileHandleTextOutputStream(.standardOutput)
        var standardErr : (any TextOutputStream) = FileHandleTextOutputStream(.standardError)
        let code = await SwiftOpenAPICLIApp().run(args: CommandLine.arguments, stdout: &standardOut, stderr: &standardErr)
        
        if code != 0 {
            exit(Int32(code))
        }
    }
}

/// A simple TextOutputStream that writes to a FileHandle.
/// 
/// This structure implements the `TextOutputStream` protocol and enables
/// writing text to a `FileHandle`. It is used to handle
/// the standard output and standard error output of the CLI.
struct FileHandleTextOutputStream: TextOutputStream {
    /// The FileHandle to write to.
    let handle: FileHandle

    /// Initializes a new TextOutputStream with the specified FileHandle.
    /// 
    /// - Parameter handle: The FileHandle to write to
    init(_ handle: FileHandle) {
        self.handle = handle
    }

    /// Writes a string to the FileHandle.
    /// 
    /// - Parameter string: The string to write
    /// 
    /// This method converts the string to UTF-8 data and writes it
    /// to the FileHandle. Errors are ignored to keep the CLI robust.
    mutating func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            try? handle.write(contentsOf: data)
        }
    }
}
