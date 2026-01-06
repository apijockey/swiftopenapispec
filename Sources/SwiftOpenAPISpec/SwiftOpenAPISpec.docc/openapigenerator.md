``openapigenerator``

This framework provides  an intermediate representation of you OpenAPI specification based on the framework SwiftOpenAPISpec, and adds both a  validator and a URL request generator.



## Overview

SwiftOpenAPISpec creates a 1:1 representation of your OpenAPI specification. This includes internal and external references, multiple type schemas (JSON schema from OAS 3.1), and legacy schema definition in in OAS 3.0

The ``OpenAPISchemaNode`` contains all type information of a schema required for validation and generation, by resolving all references and ambiguities. 

## Topics

### Intermediate Representation

- <doc:SchemaConverterGetStarted>
- ``SchemaConverter``
- ``ConverterConfig``
- ``SchemaConversionError``
- ``OpenAPISchemaNode``


### Generator
- ``SampleGenerator``


### Validator
- ``SampleValidator``

