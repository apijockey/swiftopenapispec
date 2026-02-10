//
//  Main.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 01.01.26.
//


import Foundation

@main
struct Main {
    static func main() async {
        var standardOut : (any TextOutputStream) = FileHandleTextOutputStream(.standardOutput)
        var standardErr : (any TextOutputStream) = FileHandleTextOutputStream(.standardError)
        let code = await SwiftOpenAPICLIApp().run(args: CommandLine.arguments, stdout: &standardOut, stderr: &standardErr)
        
        if code != 0 {
            exit(Int32(code))
        }
    }
}

/// Ein einfacher TextOutputStream, der auf FileHandle schreibt.
struct FileHandleTextOutputStream: TextOutputStream {
    let handle: FileHandle

    init(_ handle: FileHandle) {
        self.handle = handle
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            try? handle.write(contentsOf: data)
        }
    }
}
