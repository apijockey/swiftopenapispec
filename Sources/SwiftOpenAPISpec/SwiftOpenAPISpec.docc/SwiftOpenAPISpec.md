# ``SwiftOpenAPISpec``

Provides a cross-platform DSL for OpenAPI Specifications in Swift. 

## Overview

Use SwiftOpenAPISpec, if you want to read and write OpenAPI specifications written in Yaml and JSON using a Domain Specific Language with the Swift programming language.
Basis of the implementation is the specification on [OpenAPI Specification v3.2.0](https://spec.openapis.org/oas/v3.2.0.html)

This Swift library reads OpenAPI specifications (OAS) written in Yaml and JSON when they conform to OAS version 3.0.0 or higher, otherwise eventually fail.
The library makes no other assumptions on spec versions. 

### Featured

@Links(visualStyle: detailedGrid) {
    - <doc:GettingStarted>
    - ``OpenAPISpecification``
}

## Topics

### Getting Started

- <doc:GettingStarted>
- ``OpenAPISpecification``

### Main structs in OpenAPISpecification

- ``OpenAPIInfo``
- ``OpenAPIServer``
- ``OpenAPIPathItem``
- ``OpenAPIWebhooks``
- ``OpenAPIComponent``
- ``OpenAPISecurityScheme``
- ``OpenAPITag``
- ``OpenAPIExternalDocumentation``
- ``OpenAPIExtension``

### Components see SwiftOpenAPISpec

- ``OpenAPISchema``
- ``OpenAPIResponse``
- ``OpenAPIParameter``
- ``OpenAPIExample``
- ``OpenAPIRequestBody``
- ``OpenAPIHeader``
- ``OpenAPISecurityScheme``
- ``OpenAPILink``
- ``OpenAPICallBack``
- ``OpenAPIPathItem``
- ``OpenAPIMediaType``

### Support for multiple specification files

- <doc:ReferenceResolution>
- ``JSONPointerResolver``
- ``DocumentLoadable``
- ``YamsDocumentLoader``

### Reader strategy
- <doc:ReaderStrategy>

