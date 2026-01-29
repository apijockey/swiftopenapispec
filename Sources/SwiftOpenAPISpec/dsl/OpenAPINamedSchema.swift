///*
// * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
// *
// * Licensed under the Apache License, Version 2.0 (the "License");
// * you may not use this file except in compliance with the License.
// * You may obtain a copy of the License at
// *
// *     http://www.apache.org/licenses/LICENSE-2.0
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// */
//
////  Created by Patric Dubois on 28.03.24.
////

import Foundation


public struct OpenAPINamedElement<T>: PointerNavigable, Sendable where T: PointerNavigable, T : ThrowingHashMapInitiable {
   public init(load map: StringDictionary, objectType _: T.Type,  _ diagnostics: inout [Diagnostic]) throws {
       
       self.element = try T.init(load: map, &diagnostics)
       
    }
    
    public  var key : String? = nil
    
   
    public var element: T
    public func element(for segmentName : String) throws -> NavigationResult {
        switch segmentName {
        default :
                return try element.element(for: segmentName)
        }
    }
    
}

