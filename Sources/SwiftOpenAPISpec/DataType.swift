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
