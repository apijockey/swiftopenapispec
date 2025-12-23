# swiftopenapispec
A cross platform swift library that provides a domain specific language for OpenAPI-specifications 

## Overview

Use SwiftOpenAPISpec, if you want to read and write OpenAPI specifications written in Yaml and JSON using a Domain Specific Language with the Swift programming language.
Basis of the implementation is the specification on [OpenAPI Specification v3.2.0](https://spec.openapis.org/oas/v3.2.0.html)

This Swift library reads OpenAPI specifications (OAS) written in Yaml and JSON when they conform to OAS version 3.0.0 or higher, otherwise eventually fail.
The library makes no other assumptions on spec versions. 

## Getting Started

OpenAPI specifications are created to document an API with all of its subelements.
These specifications are written in Yaml or JSON and can be loaded using Packages like YAMS or JSONSerialization.

These represent the contents using maps/dictionaries like [String:Any?] or [Any] and allow accessing the contents using String keys.

SwiftOpenAPISpec does the heavy work of transforming these nested maps in objects that represent the terms of an OpenAPISpecification as a struct providing properties corresponding to the keys.

This gives a third party library or application full compiler support including type safety when reading the specification contents.


This library is hosted on gitlab as an Open Source Swift package.
You can use Swift Package Manager and specify the dependency in Package.siwft by adding:
.
```swift
.package(url: "https://github.com/apijockey/public/SwiftOpenAPISpec.git", from: "0.1.0")

```

### Use the package

Import the product SwiftOpenAPISpec in  your Swift files

```swift
import SwiftOpenAPISpec
```

### Read JSON 


```swift
import Foundation
import SwiftOpenAPISpec

let jsonData = """
{  
"openapi": "3.0.0",
  "info": {
    "title": "Simple API overview",
    "version": "2.0.0"
    }
}
""".data(using: .utf8)!
guard let jsonMap = try JSONSerialization.jsonObject(with: jsonData) as? StringDictionary else {
    NSError(domain: "Error", code: 1, userInfo: nil) as Error
    fatalError("Cannot read JSON")
}
let specFromJSON = try OpenAPISpecification.read(unflattened: jsonMap)
```

### Read YAML 

```swift
import Foundation
import Yams
import SwiftOpenAPISpec

let yaml = """
openapi: 3.0.0
info:
  title: Simple API overview
  version: 2.0.0
"""
guard let unflattened = try Yams.load(yaml: yaml) as? StringDictionary else {
    throw OpenAPISpecification.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
}
let specFromYaml = try OpenAPISpecification.read(unflattened: jsonMap)
```

### Read information from the ``OpenAPISpecification``

You access the information with standard properties of the ``OpenAPISpecification`` instance:
```swift
print("")
print("---")
print(specFromYaml.version!)
print(specFromYaml.info!.title)
print(specFromYaml.info!.version)
print("---")
```
will print:

```
3.0.0
Simple API overview
2.0.0
```
## 🌍 Github Pages repo docs
👉 [view on GitHub Pages](https://apijockey.github.io/swiftopenapispec/)
