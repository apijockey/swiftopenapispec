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



public struct OpenAPIAllOfType : OpenAPISchemaType, ThrowingHashMapInitiable, PointerNavigable, Equatable, Hashable {
    public static func == (l: OpenAPIAllOfType, r: OpenAPIAllOfType) -> Bool {
        
            if l.items?.count != r.items?.count {
                return false
            }
            for (i,lItem) in l.items!.enumerated() {
                if lItem != r.items![i] {
                    return false
                }
            }
            return true
        
    }
    
  
    public let type : String?
    public var items: [OpenAPISchema]?
   
  
    
    public func element(for segmentName: String) throws -> NavigationResult{
        if let index = Int(segmentName) {
            return .navigable(self.items?[index])
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return .reference( ref?.reference)
        }
        if segmentName == OpenAPISchemaReference.REF_KEY {
            if let reference = ref {
                return .reference(reference.refString)
                
            }
            else {
                throw OpenAPISpecification.Errors.notFound(segmentName)
            }
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOneOfType",segmentName)
    }
    
    public var ref: OpenAPISchemaReference?
    public static let TYPE_KEY = "allOf"
    
  

    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String) throws {
        if case .array = map[Self.TYPE_KEY] {
            self.type = "array"
        }
    
        else {
            self.type = "unknown"
            
        }
        self.items = try map.mapListIfPresent("allOf", objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: pointer)
       
    }
    
   
}
