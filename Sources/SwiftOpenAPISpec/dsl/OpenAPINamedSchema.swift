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


//public struct OpenAPINamedElement<T>: KeyedElement, PointerNavigable, Sendable where T: PointerNavigable, T : ThrowingHashMapInitiable {
//    public init(load map: StringDictionary, _ diagnostics: inout [Diagnostic]) throws {
//       fatalError("init(load:_:) has not been implemented")
//    }
//    
//   public init(load map: StringDictionary, objectType _: T.Type,  _ diagnostics: inout [Diagnostic]) throws {
//       
//       self.element = try T.init(load: map, &diagnostics)
//       
//    }
//    
//    public  var key : String? = nil
//    
//   
//    public var element: T
//    public func element(for segmentName : String) throws -> NavigationResult {
//        switch segmentName {
//        default :
//                return try element.element(for: segmentName)
//        }
//    }
//    
//}
//
//extension OpenAPINamedElement : JSONValueConvertible  {
//    public func toJSONValue() throws -> JSONValue {
//        // Basis: JSON des enthaltenen Elements
//        let elementJSON: JSONValue
//        if let convertible = element as? JSONValueConvertible {
//            elementJSON = try convertible.toJSONValue()
//        } else {
//            // Optionaler Fallback, falls du später ThrowingHashMapEncodable->toDictionary() nutzt:
//            // if let enc = element as? ThrowingHashMapEncodable {
//            //     elementJSON = .object(try enc.toDictionary())
//            // } else {
//            //     throw JSONValue.Errors.notConvertible("Element \(T.self) ist nicht JSONValueConvertible")
//            // }
//            // Aktuell: klarer Fehler, wenn T nicht konvertierbar ist.
//            throw JSONValue.Errors.notConvertible("Element \(T.self) ist nicht JSONValueConvertible")
//        }
//        
//        // Einbetten des Keys (falls vorhanden) zusammen mit dem Element
//        // Du kannst das Format frei wählen. Zwei typische Varianten:
//        // 1) { "key": "<name>", "value": <elementJSON> }
//        // 2) { "<name>": <elementJSON> } wenn key vorhanden, sonst nur das Element
//        //
//        // Ich verwende hier Variante 1, da sie stabil ist, auch wenn key nil ist.
//        var obj: [String: JSONValue] = [:]
//        obj["key"] = JSONValue(self.key)
//        obj["value"] = elementJSON
//        return .object(obj)
//    }
//    
//    // Optionaler Helper, falls du an anderer Stelle ein Any brauchst.
//    var jsonValue: Any {
//        // Liefert eine Foundation-Repräsentation, die von JSONValue.init(from:) verstanden wird.
//        // Entspricht der Struktur { "key": ..., "value": ... }
//        var dict: [String: Any] = [:]
//        dict["key"] = self.key as Any
//        // Für "value" versuchen wir, aus element ein JSONValue zu machen und dann wieder nach [String: Any]/[Any]/Primitives zu falten.
//        // Da JSONValue schon Equatable ist, kannst du es direkt einsetzen oder (falls nötig) in Foundation überführen.
//        if let convertible = element as? JSONValueConvertible,
//           let jv = try? convertible.toJSONValue() {
//            dict["value"] = jv // JSONValue selbst; falls du strikt Foundation willst, müsstest du hier rekursiv entfalten.
//        } else {
//            dict["value"] = nil
//        }
//        return dict
//    }
//}
