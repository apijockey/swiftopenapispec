# Swift Validator Starter Files (Rules + Diagnostics)


## What's included

### Diagnostics & pointers
- `JSONPointer.swift`
  - RFC 6901-compatible JSON Pointer helper (`escape`, `join`).
- `Diagnostics.swift`
  - `Diagnostic`: stable error contract (severity, code, message, pointer, rule).
  - `RefOccurrence`: what the ref-resolution rule consumes.

### Ref collection + resolution
- `SchemaRefCollector.swift`
  - Collects `$ref` occurrences from:
    - `OpenAPISchema.ref`
    - `OpenAPISchemaReference` as a schema type (e.g. inside `anyOf/oneOf/allOf` items)
    - nested object properties (`OpenAPIObjectType.properties: [OpenAPISchemaProperty]`)
    - array items (`OpenAPIArrayType.items`)
    - composition types (`OpenAPIAnyOfType`, `OpenAPIOneOfType`, `OpenAPIAllOfType`)
  - NOTE: `OpenAPISchemaProperty.schemaOrSelf` contains a **single line** you may need to adjust:
    - If `OpenAPISchemaProperty` is a wrapper: return `self.schema`
    - If it is actually `OpenAPISchema`: return `self`

- `ResolveRefsRule.swift`
  - Asynchronously resolves all collected `$ref`s using `JSONPointerResolver`.
  - Reports errors at pointers ending in `/$ref`.

### Starter schema rules
- `SchemaRules.swift`
  - Minimal schema walker (`SchemaRuleRunner`)
  - Three high-value rules:
    - Non-empty anyOf/oneOf/allOf
    - String minLength <= maxLength
    - Object required ⊆ properties

## Typical usage

1) Iterate schema roots (e.g. `apiSpec.components?.schemas ?? []`).
2) For each root schema:
   - Collect refs via `SchemaRefCollector`
   - Resolve refs via `ResolveRefsRule`
   - Run sanity rules via `SchemaRuleRunner`

## Next extensions

- Add spec-level walkers/rules for:
  - required `info`, non-empty `paths` DONE
  - `responses` required per operation DONE 
  - path parameters must be required
  - unique `operationId`
- Expand schema traversal for:
  - `additionalProperties`, `not`, 3.1/3.2 keywords as needed
