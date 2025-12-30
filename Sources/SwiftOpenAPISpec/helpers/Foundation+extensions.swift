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
//  Foundation+extensions.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 11.12.25.
//

import Foundation

extension Array where Element == String {
    public func contains(_ string: String) -> Bool {
        self.contains(where: { $0 == string })
    }
}
extension Set where Element == String {
    public func contains(_ string: String) -> Bool {
        self.contains(where: { $0 == string })
    }
}

extension Dictionary where Key == String {
    public func containsKey(_ string: String) -> Bool {
        self.keys.contains(string)
    }
}

// Free function to convert Any to String, replacing the invalid Any extension
public func stringValue(from value: Any) -> String {
    if let text = value as? String {
        return text
    } else if let bool = value as? Bool {
        return String(bool)
    } else if let number = value as? Int {
        return String(number)
    } else if let number = value as? Float {
        return String(number)
    } else if let number = value as? Double {
        return String(number)
    } else if let data = value as? Data {
        return String(data: data, encoding: .utf8) ?? ""
    } else {
        return ""
    }
}

public extension Int {
    var stringValue : String {
        get {
            return String(self)
        }
        set {
            self = Int(newValue) ?? 0
        }
    }
}
public extension Bool{
    var stringValue : String {
        get {
            return String(self)
        }
        set {
            self = Bool(newValue) ?? false
        }
    }
}
public extension Double {
    var stringValue: String? {
        return String(self)
    }
}
public extension Float {
    var stringValue: String? {
        return String(self)
    }
}
