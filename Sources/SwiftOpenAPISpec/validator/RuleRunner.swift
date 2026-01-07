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
public struct RuleRunner  : Sendable{
    public let rules: [Rule]
    public func run(spec: OpenAPISpecification, ctx: ValidationContext) -> [Diagnostic] {
        rules.flatMap { (rule: Rule) -> [Diagnostic] in
            rule.check(spec: spec, ctx: ctx)
        }
    }
    public init(rules: [Rule]) {
        self.rules = rules
    }
    public static let defaultRuleRunner : RuleRunner =  { ()
        let rules: [Rule] = [
            SupportedVersion3(),
            RequiredOpenAPIFixedFieldsRule(),
            RequiredOpenAPIFixedInfoFieldsRule(),
            RequiredPathsRule(),
            SupportedHTTPMethodRule(),
            PathsMustStartWithSlashRule(),
            RequiredLicenseNameRule(),
            SupportedHTPStatusRule(),
            RequiredServerURLRule(),
            RequiredServerVariablesRule(),
            RequiredSchemaComponentNamessRule(),
            RequiredResponsesComponentNamessRule(),
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
            ResponsesMustHaveDesccriptionRule(),
            LinkMustHaveRefOrIdentifier(),
            TagMustHaveName(),
            ReferencesMustHaveRefRule()
        ]
        return RuleRunner(rules: rules)
    }()
}
