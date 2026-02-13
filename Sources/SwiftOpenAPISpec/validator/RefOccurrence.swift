//
//  RefOccurrence.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 23.01.26.
//


/// Represents an occurrence of a reference (`$ref`) in an OpenAPI document.
/// 
/// This structure tracks where references are used within an OpenAPI specification,
/// which is essential for reference resolution, validation, and dependency analysis.
///
/// The struct is designed to be used in collections (conforms to `Equatable` and `Hashable`)
/// to enable efficient reference tracking and deduplication.
public struct RefOccurrence: Equatable, Hashable {
    /// The expected type of the reference target.
    /// 
    /// This enumeration defines what kind of object the reference is expected to resolve to.
    public enum ExpectedTarget { case schemaObject }

    /// The reference string as it appears in the document.
    /// 
    /// This is the actual `$ref` value, such as "#/components/schemas/Pet"
    /// or "definitions.yaml#/components/responses/ErrorResponse".
    public let refString: String
    
    /// A JSON Pointer that should end at "/$ref".
    /// 
    /// This pointer indicates the exact location in the document where the
    /// reference occurs, ending at the `$ref` keyword itself.
    /// 
    /// - Example: "/paths/~1pets/get/responses/200/content/application~1json/schema/$ref"
    public let pointerToDollarRef: String
    
    /// The expected type of the reference target.
    /// 
    /// This helps the validator understand what kind of object should be
    /// found when resolving the reference.
    public let expected: ExpectedTarget
    
    /// Compares two reference occurrences for equality.
    /// 
    /// Two occurrences are considered equal if they have the same reference string.
    /// This enables efficient deduplication in collections.
    /// 
    /// - Parameters:
    ///   - lhs: The left-hand side occurrence
    ///   - rhs: The right-hand side occurrence
    /// - Returns: `true` if the occurrences have the same reference string
    public static func == (lhs: RefOccurrence, rhs: RefOccurrence) -> Bool {
        return lhs.refString == rhs.refString 
    }
    
    /// Initializes a new reference occurrence.
    /// 
    /// - Parameters:
    ///   - refString: The reference string (e.g., "#/components/schemas/Pet")
    ///   - pointerToDollarRef: JSON Pointer to the `$ref` location
    ///   - expected: The expected type of the reference target
    public init(refString: String, pointerToDollarRef: String, expected: ExpectedTarget) {
        self.refString = refString
        self.pointerToDollarRef = pointerToDollarRef
        self.expected = expected
    }
}