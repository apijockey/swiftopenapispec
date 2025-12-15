//
//  DocumentLoader.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 15.12.25.
//
import Foundation

public actor DocumentLoader {
    var objectCash: [URL: OpenAPIObject] = [:]
    public enum Errors : CustomStringConvertible, LocalizedError {
        public var description: String{
            switch self {
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            
            }
        }
        
        case unreadable(String, Error)
        case notUTF8(String)
        public var errorDescription: String? {
            return description
        }
    }
    
    public func load(from url: URL) async throws -> PointerNavigable {
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8) else {
                throw Self.Errors.notUTF8(url.absoluteString)
            }
            let apiSpec = try OpenAPIObject.read(text: string, url:url.absoluteString )
            objectCash[url] = apiSpec
            return apiSpec
        } catch {
            throw Self.Errors.unreadable(url.absoluteString, error)
        }
    }
}
