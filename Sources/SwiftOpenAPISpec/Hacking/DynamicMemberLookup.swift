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

/*
 * Copyright 2025 
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

//
//  File.swift
//  
//
//  Created by Patric Dubois on 02.04.24.
//

import Foundation

@dynamicMemberLookup
struct Person {
    subscript(dynamicMember member: String) -> String {
        let properties = ["name": "Taylor Swift", "city": "Nashville"]
        return properties[member, default: ""]
    }
    subscript(dynamicMember member: String) -> Int {
            let properties = ["age": 26, "height": 178]
            return properties[member, default: 0]
    }
}
@dynamicMemberLookup
struct AddressedPerson {
    subscript(dynamicMember member: String) -> (_ input: String) -> Void {
            return {
                print("Hello! I live at the address \($0).")
            }
        }
}
@dynamicMemberLookup
enum JSON {
   case intValue(Int)
   case stringValue(String)
   case arrayValue(Array<JSON>)
   case dictionaryValue(Dictionary<String, JSON>)

   var stringValue: String? {
      if case .stringValue(let str) = self {
         return str
      }
       if case .intValue(let int) = self {
           return String(int)
       }
       return nil
   }

   subscript(index: Int) -> JSON? {
      if case .arrayValue(let arr) = self {
         return index < arr.count ? arr[index] : nil
      }
      return nil
   }

   subscript(key: String) -> JSON? {
      if case .dictionaryValue(let dict) = self {
         return dict[key]
      }
      return nil
   }

   subscript(dynamicMember member: String) -> JSON? {
      if case .dictionaryValue(let dict) = self {
         return dict[member]
      }
      return nil
   }
}
