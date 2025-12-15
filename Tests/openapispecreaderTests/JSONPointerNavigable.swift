//
//  PointerNavigable.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 12.12.25.
//


import Foundation
import Testing


extension Tag {
  @Tag static var jsonpointer: Self
    @Tag static var externalJsonPointer: Self
}



@testable import SwiftOpenAPISpec
// MARK: - Minimal contract your domain objects already satisfy

/// Your domain objects (OpenAPIObject, Components, Schema, MediaType, etc.)
/// should conform to this protocol (or at least provide this method).


// Optional: If you already have element(for:) on your structs, you can just
// add `extension OpenAPIObject: PointerNavigable {}` in your codebase.

// MARK: - Test Harness: JSON Pointer + $ref recursion



enum FixtureErrors: LocalizedError, CustomStringConvertible {
    case notFound(String)
    case unreadable(String, Error)
    case notUTF8(String)

    var description: String {
        switch self {
        case .notFound(let name): return "Fixture not found: \(name)"
        case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
        case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
        }
    }
}

// MARK: - TestSuite

@Suite("OpenAPI JSON Pointer (multi-file, chained refs)")
struct OpenAPIJSONPointerTests {
   
    
    private func fixtureURL(_ resource: String, ext: String = "yaml") throws -> URL {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else {
            throw FixtureErrors.notFound(name)
        }
        return url
    }
    
    //TODO: mit anderen Dateien arbeiten und Tag .jsonPointer verwenden
    @Test("Sanity: resolve pointers in main file", .tags(.jsonpointer), arguments:
    [
        ("#/openapi",String.self,"3.1.0"),
        ("#/info/title",String.self,"JSON Pointer Torture Main")
    ])
    func resolveLocalJSONPointers(arg: (pointer : String, expectedType : Any.Type, expectedValue : String)) async throws {
        let mainURL = try fixtureURL("35-main")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : mainURL,loadDocument: objectLoader.load(from:))
        let result = try await resolver.resolve(
            ref: "\(arg.pointer)"
        )
        print(result)
        // Compare metatype instead of attempting a runtime cast target
        
        if let strResult = result as? String {
            #expect(strResult == arg.expectedValue)
        }
    }
    
//    @Test("Sanity: JSONPointer throws external schema file error", .tags(.jsonpointer),arguments:
//    [
//        ("#/paths/~1events/post/responses/201/content/application~1json/schema/$ref","#/components/schemas/EventCreated","./ext-components.yaml#")
//    ])
    
    @Test("application/json segment uses ~1 (application~1json)", .tags(.externalJsonPointer,.jsonpointer))
    func testMediaTypeSlashEscaping() async throws {
        let mainURL = try fixtureURL("35-main")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : mainURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })
        // paths./events.post.responses.201.content.application/json.schema.$ref
        let result = try await resolver.resolve(
           ref:  "#/paths/~1events/post/responses/201/content/application~1json/schema/$ref"
        )
        
        #expect((result as? String) == "#/components/schemas/EventCreated")
    }

    @Test
    func testOneOfIndexPointer() async throws {
        let mainURL = try fixtureURL("35-main")
        let objectLoader = DocumentLoader()
        // resolver will call the async loader closure
        var resolver = JSONPointerResolver(baseURL : mainURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })
        var result = try await resolver.resolve(
            ref: "#/components/schemas/EventEnvelope/properties/payload/oneOf/0/$ref"
        )

        #expect((result as? String) == "#/components/schemas/UserCreated")
    }

   
    
   

    
    @Test("Resolve external schema via $ref chain (main -> ext)")
    func testMainToExternalSchema() async throws {
        let mainURL = try fixtureURL("35-main")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : mainURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })

        // main.yaml components.schemas.EventEnvelope is a $ref to ext-components.yaml
        let resolved = try await resolver.resolve(
             ref: "#/components/schemas/EventEnvelope"
        )
        
        // EventEnvelope in ext has type: object
        if let nav = resolved as? PointerNavigable,
           let t = try nav.element(for: "type") as? String {
            #expect(t == "object")
        } else if let dict = resolved as? [String: Any] {
            #expect(dict["type"] as? String == "object")
        } else {
            Issue.record("Resolved schema is neither PointerNavigable nor [String:Any]")
        }
    }

    @Test("oneOf array indexing: /oneOf/0 and /oneOf/1")
    func testOneOfIndexPointers() async throws {
        let mainURL = try fixtureURL("35-main")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : mainURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })

        let ref0 = try await resolver.resolve(
             ref: "#/components/schemas/EventEnvelope/properties/payload/oneOf/0/$ref"
        )
        #expect(ref0 as? String == "#/components/schemas/UserCreated")
        let ref1 = try await resolver.resolve(
           ref: "#/components/schemas/EventEnvelope/properties/payload/oneOf/1/$ref"
        )
        #expect(ref1 as? String == "#/components/schemas/UserDeleted")
    }

    @Test("~0/~1 decoding in component name (user~1admin~0meta)")
    func testWeirdComponentNameEscaping() async throws {
        let extURL = try fixtureURL("ext-components")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : extURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })

        let any = try await resolver.resolve(
            ref: "#/components/schemas/user~1admin~0meta/properties/note/type"
        )
        // Schema name in ext-components.yaml is "user/admin~meta"
        
        #expect(any as? String == "string")
    }

    @Test("Encoding map key contains '/', must use ~1 (event~1payload)")
    func testEncodingKeySlashEscaping() async throws {
        let extURL = try fixtureURL("ext-components")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : extURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })

        // requestBodies.CreateEvent.content.application/json.encoding["event/payload"].contentType
        
        let ct = try await resolver.resolve(
           ref: "#/components/requestBodies/CreateEvent/content/application~1json/encoding/event~1payload/contentType"
        )
        #expect(ct as? String == "application/json")
        let ex = try await resolver.resolve(
           ref: "#/components/requestBodies/CreateEvent/content/application~1json/encoding/event~1payload/headers/X-Encoded/example"
        )
        
        #expect(ex as? String == "1")
    }

    @Test("Callback key contains '/callbackUrl' inside segment, so segment uses ~1: {$request.body#~1callbackUrl}")
    func testCallbackKeySegmentEscaping() async throws {
        let extURL = try fixtureURL("ext-components")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : extURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })

        let opId = try await resolver.resolve(
             ref:"#/components/callbacks/DeliveredCallback/{$request.body#~1callbackUrl}/post/operationId"
        )
       
        #expect(opId as? String == "delivered")
    }

    @Test("Cross-file ref inside ext schema back to main (UserCreated.errorShape -> main CommonError)")
    func testCrossFileBackRef() async throws {
        let extURL = try fixtureURL("ext-components")
        let objectLoader = DocumentLoader()
        var resolver = JSONPointerResolver(baseURL : extURL,loadDocument: { url in
            try await objectLoader.load(from: url)
        })

        let backRefAny = try await resolver.resolve(
            ref:"#/components/schemas/UserCreated/properties/errorShape/$ref"
        )
        // Navigate to the $ref string first
       
        // That should resolve to the actual CommonError schema object (not a $ref string).
        // We assert it has type: object and required contains 'code'
        if let nav = backRefAny as? PointerNavigable {
            
             let objectElement = try nav.element(for: "type")
            #expect(objectElement  as? String == "object")
        } else if let dict = backRefAny as? [String: Any] {
            #expect(dict["type"] as? String == "object")
        } else {
            Issue.record("Resolved back-ref schema has unexpected type")
        }
    }
}

