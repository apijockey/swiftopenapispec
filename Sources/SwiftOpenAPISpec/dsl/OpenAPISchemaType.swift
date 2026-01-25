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


public protocol OpenAPISchemaType where Self : Sendable {
    
}


public struct OpenAPISchema : ThrowingHashMapInitiable {
    public static func initialize(_ map: StringDictionary) throws -> InitializationResult<OpenAPISchema> {
        let openAPISchema = OpenAPISchema()
        //if let discriminatorMap = map[Self.DISCRIMINATOR_KEY] as? StringDictionary {
            //self.discriminator = try OpenAPIDiscriminator(load: discriminatorMap)
        // }
         //self.format30 = map.readIfPresent(Self.FORMAT_KEY, String.self)
         //extensions = try OpenAPIExtension.extensionElements(map)
        return InitializationResult(value: openAPISchema, diagnostics: [])
    }
    
    var discriminator: OpenAPIDiscriminator?
    var nullable: Bool?
    var readOnly: Bool?
    var writeOnly: Bool?
    var xml: OpenAPIXMLObject?
    var externalDocs: OpenAPIExternalDocumentation?
    var example: OpenAPIExample?
    var deprecated: Bool?
    var extensions :OpenAPIExtension?
    var type : OpenAPIType?
}
