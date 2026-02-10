////
////  OpenAPIDoubleType 2.swift
////  SwiftOpenAPISpec
////
////  Created by Patric Dubois on 22.01.26.
////
//
//
//public struct OpenAPIBooleanType : OpenAPISchemaType, ThrowingHashMapInitiable  {
//    
//    
//    public static let TYPE_KEY = "type"
//    public init(load map: StringDictionary) throws {
//        self.type = map[Self.TYPE_KEY] as? String
//    }
//    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
//           let element = try Self(load: map)
//           return InitializationResult(value: element, diagnostics: [])
//       }
//
//    
//    public let type : String?
//  
//    
//    public func element(for segmentName: String) throws -> Any? {
//        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIDoubleType", segmentName)
//    }
//    
//    
//    
//   
//}
