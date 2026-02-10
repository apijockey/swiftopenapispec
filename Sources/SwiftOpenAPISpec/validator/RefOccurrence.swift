//
//  RefOccurrence.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 23.01.26.
//


public struct RefOccurrence: Equatable, Hashable {
    public enum ExpectedTarget { case schemaObject }

    public let refString: String
    /// Pointer that should end at "/$ref"
    public let pointerToDollarRef: String
    public let expected: ExpectedTarget
    public static func == (lhs: RefOccurrence, rhs: RefOccurrence) -> Bool {
        return lhs.refString == rhs.refString 
    }
    public init(refString: String, pointerToDollarRef: String, expected: ExpectedTarget) {
        self.refString = refString
        self.pointerToDollarRef = pointerToDollarRef
        self.expected = expected
    }
}