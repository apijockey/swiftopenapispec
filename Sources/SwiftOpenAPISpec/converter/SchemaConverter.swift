//
//  SchemaConverter.swift
//  openapigenerator
//
//  Created by Patric Dubois on 19.12.25.
//




/// creates an intermediate Representation for an OpenAPI specification for generators and validator tools
///
/// OpenAPI has a set of versions (3.0,3.1, 3.20) that are supported by the SchemaConverter . These have different schema dialects ( 3.1 and later use the JSON schema, validators need to cover these subtilities and generators need deterministic rules to create the content.
///
///
public struct  SchemaConverter {
    private let cfg: ConverterConfig
    private var resolver: JSONPointerResolving
    
    /// inits  a SchemaConverter with the specified config and JSONPointer
    /// - Parameters:
    ///   - config: ``ConverterConfig`` needs to distinguish OAS 3.0 schema or true JSONSchema support starting with 3.1
    ///   - resolver: ``JSONPointerResolving`` needs to resolve JSONPointers, a default implementation is available with ``SwiftOpenAPISpec/JSONPointerResolver``
    public init(config: ConverterConfig, resolver: JSONPointerResolving) {
        self.cfg = config
        self.resolver = resolver
    }
    
    /// a given ``SwiftOpenAPISpec/OpenAPISchema`` to ``OpenAPISchemaNode``
    ///
    /// ``SwiftOpenAPISpec/OpenAPISchema.schemaType``contains the concrete type information. OpenAPISchemaNode will be used by the ``SampleGenerator`` and the ``validator structs``.
    /// - Parameter schema: ``SwiftOpenAPISpec/OpenAPISchema``
    /// - Returns: an instance of``OpenAPISchemaNode``
    public mutating func convert( schema: OpenAPISchema) async throws -> OpenAPISchemaNode {
        let normalized = normalizeDialect(schema)
        if let t = normalized.schemaType {
            return try await convert(t)
        }
        else if let ref = normalized.ref {
            return try await convert(ref)
        }
        return .unsupported(reason: "Schema has no schemaType")
    }
    
    // Gemeinsame Hilfsfunktion: löst Referenzen in Items auf und liefert nur konkrete Schema-Typen zurück
    private mutating func resolveItems(_ items: [any OpenAPIValidatableSchemaType]) async throws -> [any OpenAPIValidatableSchemaType] {
        var resolvedItems = [any OpenAPIValidatableSchemaType]()
        resolvedItems.reserveCapacity(items.count)
        for item in items {
            if let reference = item as? OpenAPISchemaReference {
                let resolvedElement = try await resolve(reference)
                if let schemaType = resolvedElement.schemaType {
                    resolvedItems.append(schemaType)
                } else {
                    throw SchemaConversionError.noSchemaForReference(reference.reference ?? "")
                }
            } else {
                resolvedItems.append(item)
            }
        }
        return resolvedItems
    }
  
    mutating func convert(_ type: any OpenAPIValidatableSchemaType) async throws -> OpenAPISchemaNode {
        switch type {
        case let allOf as OpenAPIAllOfType:
            let items = allOf.items ?? []
            let resolved = try await resolveItems(items)
            return .allOf(resolved)
        case let anyOf as OpenAPIAnyOfType:
            let items = anyOf.items ?? []
            let resolved = try await resolveItems(items)
            return .anyOf(resolved)
        case let oneOf as OpenAPIOneOfType:
            let items = oneOf.items ?? []
            let resolvedItems = try await resolveItems(items)
            return .oneOf(resolvedItems)
        case let array as OpenAPIArrayType:
            return .array(array)
        case let integer as OpenAPIIntegerType:
            return .integer(integer)
        case let number as OpenAPIDoubleType:
            return .number(number)
        case let object as OpenAPIObjectType:
            return .object(object)
        case let string as OpenAPIStringType:
            return .string(string)
        case let ref as OpenAPISchemaReference:
            let referencedSchema = try await  resolve(ref)
            return try await convert(schema:referencedSchema)
        default:
            return .unsupported(reason: "Not implemented for \(type)")
        }
    }
    private mutating func resolve(_ schema: OpenAPISchemaReference) async throws -> OpenAPISchema {
        if let refName = schema.reference {
                let anyElement = try await resolver.resolve(ref:refName)
                if let schemaElement = anyElement as? OpenAPISchema {
                    return schemaElement
                }
                else {
                    throw SchemaConversionError.noSchemaForReference(schema.reference ?? "")
                }
            }
        throw SchemaConversionError.noSchemaForReference(schema.reference ?? "")
            
        }
    private func normalizeDialect(_ schema: OpenAPISchema) -> OpenAPISchema {
            // OpenAPI 3.0 nullable -> union with null
        if cfg.dialect == .oas30, schema.schemaType is OpenAPINullType {
                // Convert (type: X, nullable: true) to anyOf: [X, null]
                return schema.asAnyOfWithNull()
            }
            return schema
        }

        
}
extension OpenAPISchema {
    func asAnyOfWithNull() -> OpenAPISchema {
        // nur transformieren, wenn nullable true ist und ein konkreter Typ vorhanden ist
        guard self.nullable, let currentType = self.schemaType else {
            return self
        }
        var newItems: [any OpenAPIValidatableSchemaType] = []

        if let anyOf = currentType as? OpenAPIAnyOfType, let items = anyOf.items {
            // Prüfen, ob bereits ein Null-Typ enthalten ist
            let hasNull = items.contains { $0 is OpenAPINullType }
            newItems = items
            if !hasNull {
                newItems.append(OpenAPINullType())
            }
        } else {
            newItems = [currentType, OpenAPINullType()]
        }

        var schema = self.clone()
        schema.schemaType = OpenAPIAnyOfType(types: newItems)
        return schema

        
    }
    
}

