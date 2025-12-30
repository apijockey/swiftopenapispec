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
//  OpenAPIValidatableSchemaTypes.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public protocol OpenAPIValidatableSchemaType: ThrowingHashMapInitiable, Equatable {
    func validate() throws
    /// Polymorpher Vergleich, um Existentials (any OpenAPIValidatableSchemaType) sicher vergleichen zu können.
    /// Standard-Implementierung castet auf Self und nutzt dann Equatable.
    func isEqual(to other: any OpenAPIValidatableSchemaType) -> Bool
}

public extension OpenAPIValidatableSchemaType {
    func isEqual(to other: any OpenAPIValidatableSchemaType) -> Bool {
        guard let otherSame = other as? Self else { return false }
        return self == otherSame
    }
}
