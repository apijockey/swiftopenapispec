//
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


//public struct OpenAPIValidatableType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable, PointerNavigable  {
//    public func element(for segmentName: String) throws -> Any? {
//        if segmentName == OpenAPISchemaReference.REF_KEY {
//            return ref
//        }
//        throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIValidatableType", segmentName)
//    }
//    
//    
//    
//  
//   
//    public init(_ map: [String : Any]) throws {
//        self.ref = map[OpenAPISchemaReference.REF_KEY] as? String
//        
//        
//    }
//    public func validate() throws {
//        
//    }
//    public let ref : String?
//    public var userInfos =  [OpenAPIObject.UserInfo]()
//     
//}
