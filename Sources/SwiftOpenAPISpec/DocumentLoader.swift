//
//  DocumentLoader.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 15.12.25.
//
import Foundation
import Yams

/**
 Used in ``OpenAPISpecification`` to read referenced Yaml/JSON files when referenced by a JSONPointer.
 
 This package provides a default implementation with ``YamsDocumentLoader`` using the Yams package.
 */
public protocol DocumentLoadable {
    func load(from url: URL) async throws -> OpenAPISpecification
}


/// Default implementation for the ``DocumentLoadable`` protocol which is a required parameter.
public actor YamsDocumentLoader : DocumentLoadable {
    private var objectCash: [URL: OpenAPISpecification] = [:]
    
    /// inits an instance of the object.
    ///
    /// The YamsDocumentLoader keeps an internal map of urls to OpenAPISpecifications and loads the contents of an OpenAPI specification using the Yams package.
    public init() {
        
    }
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
    
    public func load(from url: URL) async throws -> OpenAPISpecification {
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8) else {
                throw Self.Errors.notUTF8(url.absoluteString)
            }
            guard let unflattened = try Yams.load(yaml: string) as? StringDictionary else {
                throw OpenAPISpecification.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
            }
            
            var apiSpec = try OpenAPISpecification(unflattened)
            apiSpec.documentLoader = self
            objectCash[url] = apiSpec
            return apiSpec
        } catch {
            throw Self.Errors.unreadable(url.absoluteString, error)
        }
    }
}
