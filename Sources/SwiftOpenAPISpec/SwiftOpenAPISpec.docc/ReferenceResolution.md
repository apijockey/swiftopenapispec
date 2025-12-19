# ReferenceResolution

An OpenAPI specification can be split in several files. This article describes the supported reference types and the resolution strategy.


Several elements can contain a JSON reference which itself is expressed as a JSONPointer with a relative URI or a internal JSON reference

## Overview

Referencing elements is a regular element when designing OpenAPI specifications. 
Some examples:

### JSON References:

Lets discuss this specification fragment. This is a path item which references a definition in components -> pathItems -> EventBy Id.
A JSON reference is identified by the _$ref_ key.

```yaml
/events/{eventId}:
  $ref: "#/components/pathItems/EventById"
```

The referenced elements could look like this, as you see this elmeent uses a reference again.
```
EventById:
  parameters:
    - name: eventId
      in: path
      required: true
      schema: { type: string }
  get:
    operationId: getEvent
    responses:
      "200":
        description: OK
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/EventEnvelope"
      "404":
        description: Not found
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CommonError"
```
SwiftOpenAPISpec will store the JSON reference string in the element  

### Section header

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->
