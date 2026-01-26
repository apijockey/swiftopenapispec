/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//  Created by Patric Dubois on 26.03.24.
//


import Foundation


public struct OpenAPIServer : ThrowingHashMapInitiable , PointerNavigable {
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.DESCRIPTION_KEY :  return .value(JSONValue(self.description))
            case Self.URL_KEY : return .value(JSONValue(url))
        case Self.NAME_KEY :return .value(JSONValue(name))
        case Self.VARIABLES_KEY : return try variables.element(for: segmentName)
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIInfo", segmentName)

        }
        
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public static let DESCRIPTION_KEY = "description"
    public static let URL_KEY = "url"
    public static let NAME_KEY = "name"
    public static let VARIABLES_KEY = "variables"
   
    
    public init(url:String){
        self.url = url
    }
    public init(load map: StringDictionary) throws {
        self.url = map.readIfPresent(Self.URL_KEY, valueType: String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType:  String.self)
        self.name = map.readIfPresent(Self.NAME_KEY, valueType: String.self)
        self.variables = try map.mapListIfPresent(Self.VARIABLES_KEY,objectType : OpenAPIVariable.self)
        extensions = try OpenAPIExtension.extensionElements(map)
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public var description : String? = nil
    public var extensions : [OpenAPIExtension]?
    public var name : String? = nil
    public var url : String? = "/"
   
    //https://spec.openapis.org/oas/latest.html#server-variable-object
    public var variables : [OpenAPIVariable] = []
    
    
     
    
}
public extension Array where Element == OpenAPIServer {
    subscript (url urlString : String) -> OpenAPIServer? {
        return self.first { server in
            server.url == urlString
        }
    }
}
