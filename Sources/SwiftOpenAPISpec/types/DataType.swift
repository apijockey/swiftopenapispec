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
//  DataType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 16.12.25.
//

public enum DataType : String, CaseIterable {
        case null, boolean, object, array, number, string, integer
    }
public enum DateFormatType : String, CaseIterable {
    case datetime = "date-time", date,time, duration
}
public enum EmailFormatType : String, CaseIterable {
    case email, idnEmail="idn-email"
}
public enum HostnameFormatType : String, CaseIterable {
    case hostname, idnHostname="idn-hostname"
    
}

public enum IPAddressFormatType : String, CaseIterable {
    case ipv4, ipv6
    
}
public enum RessourceIdentifierFormatType : String, CaseIterable {
    case uri, uriReference="uri-reference", iri, iriReference="iri-reference", uuid
    
}

public enum JSONPointerFormatType : String, CaseIterable {
    case jsonPointer="json-pointer",relativeJsonPointer="relative-json-pointer"
    
}
public enum StringFormatType : String, CaseIterable {
    case regex, password
    
}
