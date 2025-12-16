//
//  File.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation
public struct OpenAPIRequestBody : KeyedElement , PointerNavigable {
    public static let DESCRIPTION_KEY = "description"
    public static let REQUIRED_KEY = "required"
    public static let CONTENTS_KEY = "content"
    public init(_ map: [String : Any]) throws {
       
       
        if let contentsMap = map[Self.CONTENTS_KEY] as? [String : Any]{
            self.contents = try KeyedElementList.map(contentsMap )
        }
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                    self.ref = try OpenAPISchemaReference(refMap)
        }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
        }
        self.required = map.readIfPresent(Self.REQUIRED_KEY, Bool.self) ?? false
        
    }
    public var key : String?
    
    public var description : String? = nil
    public var required : Bool = false
    public var contents : [OpenAPIMediaType] = []
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var ref : OpenAPISchemaReference? = nil
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
        case Self.CONTENTS_KEY : return self.contents
            default : throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIRequestBody", segmentName)
        }
    }
    
}

