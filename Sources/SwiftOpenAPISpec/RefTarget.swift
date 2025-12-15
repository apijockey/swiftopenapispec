//
//  RefTarget 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 15.12.25.
//

import Foundation
public struct RefTarget: Hashable, CustomDebugStringConvertible, CustomStringConvertible  {
    public var description: String {
        return debugDescription
    }
    
    public var debugDescription: String {
        return """
            url : \(url.absoluteString)
            fragment : \(fragment)
            """
    }
    
    public let url: URL
    public let fragment: String // e.g. "#/components/schemas/User"
}

