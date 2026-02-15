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
            WebhookSupport30Rule(),
            RequiredOpenAPI30FixedFieldsRule(),
            RequiredOpenAPIFixedInfoFieldsRule(),
            OpenAPIInfoV30FieldsNotAllowed(),
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
            RequiredResponsesComponentNamessRule(),
            OpenAPIResponse30_ValidFieldsRule(),
            RequiredExamplesComponentNamessRule(),
            RequiredRequestBodiesComponentsNamessRule(),
            RequiredsHeaderComponentsNamessRule(),
            RequiredSecuritySchemeComponentsNamessRule(),
            RequiredLinksComponentsNamessRule(),
            RequiredCallBackomponentsNamessRule(),
            OperationMustHaveResponsesRule(),
            ExternalDocumentationMustHaveURLRule(),
            ParameterLocationsMustHaveInRule(),
            RequestBodiesMustHaveContentRule(),
            ResponsesMustHaveDescriptionRule(),
            LinkMustHaveRefOrIdentifier(),
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
            RequiredResponsesComponentNamessRule(),
            RequiredExamplesComponentNamessRule(),
            OpenAPIMediaTypeV30_1ItemFieldsNotAllowed(),
            RequiredRequestBodiesComponentsNamessRule(),
            OpenAPIResponse30_ValidFieldsRule(),
            RequiredsHeaderComponentsNamessRule(),
            RequiredSecuritySchemeComponentsNamessRule(),
            RequiredLinksComponentsNamessRule(),
            RequiredCallBackomponentsNamessRule(),
            OperationMustHaveResponsesRule(),
            ExternalDocumentationMustHaveURLRule(),
            ParameterLocationsMustHaveInRule(),
            RequestBodiesMustHaveContentRule(),
            ResponsesMustHaveDescriptionRule(),
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
                let pointer = JSONPointer.join(pathItem.pointer, operation.key ?? operation.operationId ?? "")
                items.append((item:operation,  pointer: pointer))
            }
            for operation in pathItem.item.additionalOperations {
                let pointer = JSONPointer.join(pathItem.pointer, operation.key ?? operation.operationId ?? "")
                items.append((item:operation,  pointer: pointer))
            }
        }
        return items
    }
    public static func responseInfo(spec: OpenAPISpecification) -> [(item: OpenAPIResponse, pointer:String)] {
        var items =  [(OpenAPIResponse, String)]()
        for operationInfo in operationsInfo(spec: spec) {
            for response in operationInfo.item.responses {
                let pointer = JSONPointer.join(operationInfo.pointer, JSONPointer.join("responses",response.key ?? ""))
                items.append((item: response,  pointer: pointer))
            }
                
        }
        return items
    }
    public static func requestBodyInfo(spec: OpenAPISpecification) -> [(item: OpenAPIRequestBody, pointer:String)] {
        var items =  [(OpenAPIRequestBody, String)]()
        for operationInfo in operationsInfo(spec: spec) {
            if let requestBody = operationInfo.item.requestBody {
                let pointer = JSONPointer.join(operationInfo.pointer, JSONPointer.join("requestBody",requestBody.key ?? ""))
                items.append((item: requestBody,  pointer: pointer))
            }
           
        }
        return items
    }
    public static func mediaTypes(spec: OpenAPISpecification) -> [(item: OpenAPIMediaType, pointer:String)] {
        var items =  [(OpenAPIMediaType, String)]()
        for requestBody in requestBodyInfo(spec: spec) {
            for content in requestBody.item.contents {
                let pointer = JSONPointer.join(requestBody.pointer,content.key ?? "")
                items.append((item: content,  pointer: pointer))
            }
        }
        for response in responseInfo(spec: spec) {
            for content in response.item.content {
                let pointer = JSONPointer.join(response.pointer,content.key ?? "")
                items.append((item: content,  pointer: pointer))
            }
        }
        return items
    }
}
