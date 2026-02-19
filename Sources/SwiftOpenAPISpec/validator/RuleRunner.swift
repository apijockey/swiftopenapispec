/* Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
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
//  Created by Patric Dubois on 02.01.2026.
//
/// Executes validation rules against OpenAPI specifications.
/// 
/// The RuleRunner is responsible for orchestrating the validation process
/// by applying a collection of rules to an OpenAPI document. It:
/// - Maintains a set of validation rules
/// - Executes all rules against a specification
/// - Collects and returns all diagnostics (validation findings)
/// - Provides a default set of rules for standard validation
///
/// The runner is designed to be thread-safe (`Sendable`) and can be
/// used in concurrent validation scenarios.
public struct RuleRunner  : Sendable{
    /// The collection of validation rules to be executed.
    public let rules: [Rule]
    
    /// Executes all validation rules against an OpenAPI specification.
    ///
    /// - Parameters:
    ///   - spec: The OpenAPI specification to validate
    ///   - ctx: The validation context
    /// - Returns: An array of diagnostics (validation findings) from all rules
    ///
    /// This method applies each rule in sequence and collects all findings.
    /// Rules that return empty arrays indicate no issues were found.
    public func run(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        rules.flatMap { (rule: Rule) -> [Diagnostic] in
            rule.check(spec: spec, ctx: ctx)
        }
    }
    
    /// Initializes a new RuleRunner with a custom set of rules.
    ///
    /// - Parameter rules: The validation rules to use
    public init(rules: [Rule]) {
        self.rules = rules
    }
    
    /// The default RuleRunner with the standard set of validation rules.
    ///
    /// This includes rules for:
    /// - Version validation
    /// - Structural validation
    /// - Schema validation
    /// - Reference validation
    /// - And other core OpenAPI requirements
    private static let oas30RuleRunner : RuleRunner =  { ()
        
        
        let rules: [Rule] = [
            SupportedVersion3(),
            OpenAPISpecificationV30FieldsNotAllowed(),
            RequiredOpenAPI30FixedFieldsRule(),
            RequiredOpenAPIFixedInfoFieldsRule(),
            OpenAPIInfoV30FieldsNotAllowed(),
            OpenAPILicenseV30FieldsNotAllowed(),
            RequiredPathsRule(),
            OpenAPIPathV30_ItemFieldsNotAllowed(),
            SupportedHTTPMethodRule(),
            PathsMustStartWithSlashRule(),
            RequiredLicenseNameRule(),
            SupportedHTPStatusRule(),
            RequiredServerURLRule(),
            RequiredServerVariablesRule(),
            RequiredSchemaComponentNamessRule(),
            OpenAPIComponentV30FieldsNotAllowed(),
            OpenAPIComponentV30_1FieldsNotAllowed(),
            OpenAPIMediaTypeV30_1ItemFieldsNotAllowed(),
            OpenAPIExample30_ValidFieldsRule(),
            
            RequiredResponsesComponentNamessRule(),
            OpenAPIResponse30_ValidFieldsRule(),
            RequiredExamplesComponentNamessRule(),
            RequiredRequestBodiesComponentsNamessRule(),
            RequiredsHeaderComponentsNamessRule(),
            RequiredSecuritySchemeComponentsNamessRule(),
            
            RequiredLinksComponentsNamessRule(),
            RequiredCallBackomponentsNamessRule(),
            OpenAPITag30_ValidFieldsRule(),
            OperationMustHaveResponsesRule(),
            ExternalDocumentationMustHaveURLRule(),
            ParameterLocationsMustHaveInRule(),
            OpenAPIDiscriminator30_ValidFieldsRule(),
            OpenAPIXMLObject_ValidFieldsRule(),
            RequestBodiesMustHaveContentRule(),
            ResponsesMustHaveDescriptionRule(),
            LinkMustHaveRefOrIdentifier(),
            OpenAPISecurityScheme_ValidFieldsRule(),
            OpenAPIOAuthFlow_ValidFieldsRule(),
            TagMustHaveName(),
            ReferencesMustHaveRefRule()
        ]
        return RuleRunner(rules: rules)
    }()
    
    /// The default RuleRunner with the standard set of validation rules.
    ///
    /// This includes rules for:
    /// - Version validation
    /// - Structural validation
    /// - Schema validation
    /// - Reference validation
    /// - And other core OpenAPI requirements
    private static let oas31RuleRunner : RuleRunner =  { ()
        
        
        let rules: [Rule] = [
            SupportedVersion3(),
            RequiredOpenAPI31FixedFieldsRule(),
            RequiredOpenAPIFixedInfoFieldsRule(),
            RequiredPathsRule(),
            SupportedHTTPMethodRule(),
            PathsMustStartWithSlashRule(),
            RequiredLicenseNameRule(),
            SupportedHTPStatusRule(),
            ValidComponentNamesRule(),
            RequiredServerURLRule(),
            RequiredServerVariablesRule(),
            RequiredSchemaComponentNamessRule(),
            OpenAPIComponentV30_1FieldsNotAllowed(),
            OpenAPIPathV30_ItemFieldsNotAllowed(),
            OpenAPIMediaTypeV30_1ItemFieldsNotAllowed(),
            OpenAPITag30_ValidFieldsRule(),
            RequiredResponsesComponentNamessRule(),
            RequiredExamplesComponentNamessRule(),
            OpenAPIMediaTypeV30_1ItemFieldsNotAllowed(),
            RequiredRequestBodiesComponentsNamessRule(),
            OpenAPIExample30_ValidFieldsRule(),
            OpenAPIResponse30_ValidFieldsRule(),
            RequiredsHeaderComponentsNamessRule(),
            OpenAPIDiscriminator30_ValidFieldsRule(),
            RequiredSecuritySchemeComponentsNamessRule(),
            RequiredLinksComponentsNamessRule(),
            RequiredCallBackomponentsNamessRule(),
            OperationMustHaveResponsesRule(),
            ExternalDocumentationMustHaveURLRule(),
            ParameterLocationsMustHaveInRule(),
            RequestBodiesMustHaveContentRule(),
            ResponsesMustHaveDescriptionRule(),
            OpenAPIXMLObject_ValidFieldsRule(),
            OpenAPISecurityScheme_ValidFieldsRule(),
            OpenAPIOAuthFlow_ValidFieldsRule(),
            LinkMustHaveRefOrIdentifier(),
            TagMustHaveName(),
            ReferencesMustHaveRefRule()
        ]
        return RuleRunner(rules: rules)
    }()
    public init(version: ValidationContext.OASVersion) {
        switch version {
        case .v30:
            self = Self.oas30RuleRunner
        case .v31:
            self = Self.oas31RuleRunner
        case .v32:
            self = Self.oas31RuleRunner
        }
    }
    public static func pathItemInfo(spec: OpenAPISpecification) -> [(item: OpenAPIPathItem, pointer:String)] {
        var items =  [(OpenAPIPathItem, String)]()
        for pathItem in spec.paths {
            
            let pointer = "#/paths/\(JSONPointer.escape(pathItem.key ?? ""))"
            items.append((pathItem,  pointer))
            
        }
        for pathItem in spec.components?.pathItems ?? [] {
            
            let pointer = "#/components/pathItems/\(JSONPointer.escape(pathItem.key ?? ""))"
            items.append((pathItem,  pointer))
            
            
        }
        return items
    }
    public static func operationsInfo(spec: OpenAPISpecification) -> [(item: OpenAPIOperation, pointer:String)] {
        var items =  [(OpenAPIOperation, String)]()
        for pathItem in pathItemInfo(spec: spec) {
            for operation in pathItem.item.operations {
                let pointer = "\(pathItem.pointer)/\(operation.key ?? operation.operationId ?? "")"
                items.append((item:operation,  pointer: pointer))
            }
            for operation in pathItem.item.additionalOperations {
                let pointer = "\(pathItem.pointer)/\(operation.key ?? operation.operationId ?? "")"
                items.append((item:operation,  pointer: pointer))
            }
        }
        return items
    }
    public static func responseInfo(spec: OpenAPISpecification) -> [(item: OpenAPIResponse, pointer:String)] {
        var items =  [(OpenAPIResponse, String)]()
        for operationInfo in operationsInfo(spec: spec) {
            for response in operationInfo.item.responses {
                let pointer = "\(operationInfo.pointer)/responses/\(response.key ?? "")"
                items.append((item: response,  pointer: pointer))
            }
            
        }
        for response in spec.components?.responses ?? [] {
            let pointer = "#/components/responses/\(response.key ?? "")"
            items.append((item: response,  pointer: pointer))
        }
        return items
    }
    public static func requestBodyInfo(spec: OpenAPISpecification) -> [(item: OpenAPIRequestBody, pointer:String)] {
        var items =  [(OpenAPIRequestBody, String)]()
        for operationInfo in operationsInfo(spec: spec) {
            if let requestBody = operationInfo.item.requestBody {
                var pointer = "\(operationInfo.pointer)/requestBody"
                if requestBody.key != nil {
                    pointer.append("/\(requestBody.key ?? "")")
                }
                items.append((item: requestBody,  pointer: pointer))
            }
            
        }
        for requestBody in (spec.components?.requestBodies ?? []) {
            
            let pointer = "#/components/requestBodies/\(requestBody.key ?? "")"
            items.append((item: requestBody,  pointer: pointer))
        }
        return items
    }
    public static func mediaTypes(spec: OpenAPISpecification) -> [(item: OpenAPIMediaType, pointer:String)] {
        var items =  [(OpenAPIMediaType, String)]()
        for requestBody in requestBodyInfo(spec: spec) {
            for content in requestBody.item.contents {
                let pointer = "\(requestBody.pointer)/content/\(JSONPointer.escape(content.key ?? ""))"
                items.append((item: content,  pointer: pointer))
            }
        }
        for response in responseInfo(spec: spec) {
            for content in response.item.content {
                let pointer = "\(response.pointer)/content/\(JSONPointer.escape(content.key ?? ""))"
                items.append((item: content,  pointer: pointer))
            }
        }
        return items
    }
    public static func headerInfo(spec: OpenAPISpecification) -> [(item: OpenAPIHeader, pointer:String)] {
        var items =  [(OpenAPIHeader, String)]()
        if let headers = spec.components?.headers?.map ({ header in
            (item:header, pointer: "#/components/headers/\(header.key ?? "")")
        }) {
            items.append(contentsOf: headers)
        }
        for responseInfo in responseInfo(spec: spec) {
            let response = responseInfo.item
            let pointer = responseInfo.pointer
            let headersInfo = response.headers.map { header in
                (item:header, pointer: "\(pointer)/\(header.key ?? "")")
            }
            items.append(contentsOf:headersInfo)
            
        }
        for mediaTypeInfo in mediaTypes(spec: spec) {
            
            let mediaType = mediaTypeInfo.item
            let pointer = mediaTypeInfo.pointer
            
            for encoding in mediaType.encoding{
                for header in encoding.headers {
                    items.append((item: header, pointer: "\(pointer)/encoding/\(encoding.key ?? "")/headers\(header.key ?? "")"))
                }
            }
            if let encoding = mediaType.itemEncoding {
                for header in encoding.headers {
                    items.append((item: header, pointer: "\(pointer)/itemEncoding/\(encoding.key ?? "")/headers\(header.key ?? "")"))
                }
            }
            for encoding in mediaType.prefixEncoding{
                for header in encoding.headers {
                    items.append((item: header, pointer: "\(pointer)/prefixEncoding/\(encoding.key ?? "")/headers\(header.key ?? "")"))
                }
            }
            
        }
        return items
    }
    public static func examplesInfo(spec: OpenAPISpecification) -> [(item: OpenAPIExample, pointer:String)] {
        var items =  [(OpenAPIExample, String)]()
        if let examples = spec.components?.examples?.map ({ example in
            return (item: example, pointer: "#/components/examples/\(example.key ?? "")")
        }) {
            items.append(contentsOf: examples)
        }
        
        let mediaTypeInfos = mediaTypes(spec: spec)
        for mediaTypeInfo in mediaTypeInfos {
            let mediaType = mediaTypeInfo.item
            let pointer = mediaTypeInfo.pointer
            
            for example in mediaType.examples {
                items.append((item: example, pointer: "\(pointer)/examples/\(example.key ?? "")"))
            }
            
            
        }
        for headerInfo in headerInfo(spec: spec) {
            let header = headerInfo.item
            let pointer = headerInfo.pointer
            
            for example in header.examples {
                items.append((item: example, pointer: "\(pointer)/examples/\(example.key ?? "")"))
            }
        }
        
        return items
    }
    public static func schemasInfo(spec: OpenAPISpecification) -> [(item: OpenAPISchema, pointer:String)] {
        var items =  [(OpenAPISchema, String)]()
        if let schemas = spec.components?.schemas {
            for namedSchema in schemas {
                let pointer = "#/components/schemas/\(namedSchema.key ?? "")"
                items.append(contentsOf: schemasInfo(schema: namedSchema, pointer: pointer))
                
            }
        }
        for info in RuleRunner.mediaTypes(spec: spec)  {
            let pointer = info.pointer
            let content = info.item
            if let schema = content.schema  {
                let pointer = "\(pointer)/schema/\(schema.key ?? "")"
                items.append(contentsOf: schemasInfo(schema: schema, pointer: pointer))
            }
        }
        return items
    }
    public static func schemasInfo(schema: OpenAPISchema, pointer: String) -> [(item: OpenAPISchema, pointer:String)] {
        var schemas: [(item: OpenAPISchema, pointer:String)] = []
        schemas.append((item: schema, pointer: pointer))
        if let type =  schema.type {
            
            if case let .object(obj) = type {
                for prop in obj.properties {
                    if let key = prop.key{
                        let p = JSONPointer.join(JSONPointer.join(pointer, "properties"), key)
                        schemas.append(contentsOf: schemasInfo(schema: prop , pointer: p))
                    }
                    
                }
                if let unevaluatedProperties = obj.unevaluatedProperties,
                   case let .schema(schemaObject) = unevaluatedProperties {
                    for prop in schemaObject {
                        if let key = prop.key{
                            let p = JSONPointer.join(JSONPointer.join(pointer, "unevaluatedProperties"), key)
                            schemas.append(contentsOf: schemasInfo(schema: prop , pointer: p))
                        }
                        
                    }
                }
                if let additionalProperties = obj.additionalProperties,
                   case let .schema(schemaObject) = additionalProperties  {
                    for prop in schemaObject {
                        if let key = prop.key{
                            let p = JSONPointer.join(JSONPointer.join(pointer, "additionalProperties"), key)
                            schemas.append(contentsOf: schemasInfo(schema: prop , pointer: p))
                        }
                        
                    }
                }
                for prop in obj.patternProperties {
                    if let key = prop.key{
                        let p = JSONPointer.join(JSONPointer.join(pointer, "patternProperties"), key)
                        schemas.append(contentsOf: schemasInfo(schema: prop , pointer: p))
                    }
                    
                }
            }
            
            if case let .array(arr) = type ,
               let items = arr.items {
                    schemas.append(contentsOf: schemasInfo(schema: items, pointer: JSONPointer.join(JSONPointer.join(pointer, "items"), "")))
                
            }
            
            if case let .anyOf(openAPIAnyOfType) = type,
               let items = openAPIAnyOfType.items {
                for (idx, item) in items.enumerated() {
                    schemas.append(contentsOf: schemasInfo(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "anyOf"), "\(idx)")))
                }
                
            }
            
            if case let .oneOf(openAPIAnyOfType) = type ,
               let items = openAPIAnyOfType.items {
                for (idx, item) in items.enumerated() {
                    schemas.append(contentsOf: schemasInfo(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "oneOf"), "\(idx)")))
                }
                
            }
            
            if case let .allOf(openAPIAnyOfType) = type,
               let items = openAPIAnyOfType.items {
                for (idx, item) in items.enumerated() {
                    schemas.append(contentsOf: schemasInfo(schema: item, pointer: JSONPointer.join(JSONPointer.join(pointer, "allOf"), "\(idx)")))
                }
                
            }
            
            
            
            if case  .ref = type {
                return schemas
            }
            return schemas
        }
        return schemas
    }
}
