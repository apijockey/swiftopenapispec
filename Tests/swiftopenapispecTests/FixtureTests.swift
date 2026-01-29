/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
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
//  Created by Patric Dubois on 30.11.25.
//

import Foundation
import Yams
import Testing
@testable import SwiftOpenAPISpec

struct FixtureTests {
    enum Errors: LocalizedError, CustomStringConvertible {
        case notFound(String)
        case unreadable(String, Error)
        case notUTF8(String)

        var description: String {
            switch self {
            case .notFound(let name): return "Fixture not found: \(name)"
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            }
        }
    }
    private func fixtureMap(_ resource: String, ext: String = "yaml", subDirectory : String? = nil) throws -> JSONValue {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw Self.Errors.notFound(name)
        }

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string)  as? [String:Any] else  {
                throw Self.Errors.notUTF8(name)
            }
            let jsonValue = try JSONValue(from: map) 
            return jsonValue
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
   
    @Test("minimal-3_0/Parser-Happy-Path für 3.0.x.")
    func minimal() async throws {
        guard case let .object(yaml) = try fixtureMap("01-minimal-30", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"minimal-3_0" , documentLoader: YamsDocumentLoader())
        #expect(apiSpec.version == "3.0.3")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping"].first)
        #expect(getPingOperation.responses.count == 1)
    
    }
    @Test("02 3.1-Path, jsonSchema dialect, modernere Keywords „fit through“.")
    func modernKeywords() async throws {
        guard case let .object(yaml) = try fixtureMap("02-minimal-31", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"02-minimal-31" , documentLoader: YamsDocumentLoader())
        #expect(apiSpec.version == "3.1.0")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping31"].first)
        #expect(getPingOperation.responses.count == 1)
        let responses = getPingOperation.responses
        #expect(responses.count == 1)
        guard let getPing200Response = getPingOperation.response(httpstatus:  "200") else {
            return
        }
        
        let contentType = getPing200Response.content[key: "application/json"]
        guard let contentType = contentType else {
            Issue.record("Content Type is nil")
            return
        }
        
         #expect(getPing200Response.content.count == 1)
       
        guard case let .object(objectType) = contentType.schema?.type else {
            Issue.record("Could not extract object schema from: \(String(describing: contentType.schema))")
            return
        }
        
        print(objectType.properties.count)
        #expect(objectType.unevaluatedProperties == false)
        #expect(objectType.properties.count == 1)
        #expect(contentType.schema?.required?.count == 1)
        #expect(contentType.schema?.required?.first == "ok")
       
        
    }
    @Test("03-pathitems, parameter matrix, operations, additional operations")
    func pathitems() async throws {
        guard case let .object(yaml) = try fixtureMap("03-pathitems", subDirectory: "Resources/3_2/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"03-pathitems", documentLoader: YamsDocumentLoader())
        let path = try #require(apiSpec[path: "/pets/{id}"])
        #expect(path.description == "Returns pets information")
        #expect(path.summary == "get Pets")
        let parameters = try #require(path.operations[operationID : "getPet"]?.parameters)
        
        guard parameters.count == 1,
              let parameter = parameters.first else { Issue.record("one parameter expected"); return }
        #expect(parameter.name == "id")
        #expect(parameter.location == SwiftOpenAPISpec.OpenAPIParameter.ParameterLocation.path)
        guard case  .string = parameter.schema?.type   else { Issue.record("string expected"); return }
        
        #expect(parameter.explode == nil)
        #expect(parameter.deprecated == nil)

        let searchPath = try #require(apiSpec[path: "/pets"])
        let searchParameters = try #require(searchPath.operations[operationID : "searchPets"]?.parameters)
        let copyOperation = try #require(searchPath.additionalOperations[operationID : "copyPetsById"])
        
        
        #expect(parameters.count == 1)
        let queryParameter = try #require(searchParameters.first { $0.name == "limit" })
        
        #expect(queryParameter.location == OpenAPIParameter.ParameterLocation.query)
        let schema = try #require(queryParameter.schema)
        guard case .integer = schema.type   else { Issue.record("integer expected"); return }
        guard case .integer(let defaultValue) = schema.defaultValue else {
            Issue.record(".number expected for defaultValue")
            return
        }
        #expect(defaultValue == 10)
        #expect(schema.minimum == 1.0)
        #expect(schema.maximum == 100.0)
        
    }
    
    @Test("04-requestbody-media-types")
    func mediatypes() async throws {
        guard case let .object(yaml) = try fixtureMap("04-requestbody-media-types", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"04-requestbody-media-types", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 2)
        
    }
    
    @Test("04a-requestbody-media-types-enum")
    func enumtypes() async throws {
        guard case let .object(yaml) = try fixtureMap("04a-requestbody-media-types-enum", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"04a-requestbody-media-types-enum", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 1)
        guard case .string  = try #require(requestbodyContents[0].schema?.type ) else {
            Issue.record("Failed to extract string schema")
            return
        }
        #expect(requestbodyContents[0].schema?.allowedValues == ["Alice","Bob","Carl"])
        
        
    }
    
    @Test("04b-requestbody-media-types-object")
    func arraytypes() async throws {
        guard case let .object(yaml) = try fixtureMap("04b-requestbody-media-types-object", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"04b-requestbody-media-types-object", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 1)
        guard case let .object(objectType) = try #require(requestbodyContents[0].schema?.type ) else {
            Issue.record("Failed to extract object schema")
            return
        }
        #expect(objectType.properties.count == 2)
        #expect(objectType.properties.contains(where:{$0.key == "productName"}))
        #expect(objectType.properties.contains(where:{$0.key == "productPrice"}))
        //#expect(objectType.properties[key: "productName"]?.schema?.type is OpenAPIStringType)
        //#expect(objectType.properties[key: "productPrice"]?.schema?.type is  OpenAPINumberType)
        
        
    }
    
    @Test("05-responses-status-default")
    func components() async throws {
        guard case let .object(yaml) = try fixtureMap("05-responses-status-default", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"05-responses-status-default", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/create"]?.operations)
        #expect(operations.count == 1)
        
        let response201 = try #require(apiSpec[path: "/create"]?.operations[operationID : "create"]?.response(httpstatus: "201"))
        #expect(response201.description == "created")
        guard case let .object(objectType) = try #require(response201.content.first?.schema?.type ) else { Issue.record(); return }
        #expect(objectType.required.first  == "id")
        #expect(objectType.required.count  == 1)
        let defaultResponse = try #require(apiSpec[path: "/create"]?.operations[operationID : "create"]?.response(httpstatus: "default"))
        #expect(defaultResponse.description == "error")
        guard case let .ref(component) = try #require(defaultResponse.content.first?.schema?.type ) else { Issue.record(); return }
        #expect(component.reference == "#/components/schemas/Error")
    }
    
    @Test("tictactor-nested-array-elements")
    func nestedArrayElements() async throws {
        guard case let .object(yaml) = try fixtureMap("tictactoe", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"tictactoe", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/board"]?.operations)
        #expect(operations.count == 1)
        #expect(operations.first?.response(httpstatus: "200")?.content.count == 1)
        guard case let .object(objectType) = try #require(operations.first?.response(httpstatus: "200")?.content.first?.schema?.type ) else { Issue.record(); return }
        #expect(objectType.properties.count == 2)
        let winnerProperty = try #require(objectType.properties.first(where: { $0.key == "winner" }))
        let schema = winnerProperty.element
        //guard case let .string(stringPropertyInfo) = try #require(schema.type) else { Issue.record(); return }
        #expect(schema.allowedValues == ["X", "O", "."])
        let boardProperty = try #require(objectType.properties.first(where: { $0.key == "board" }))
        
        #expect(boardProperty.element.maxItems == 3)
        #expect(boardProperty.element.minItems == 3)
        guard case let .array(boardSubItems) = try #require(boardProperty.element.type ) else { Issue.record(); return }
        guard case  .array = try #require(boardSubItems.items?.type) else { Issue.record(); return }

        
    }
    
    @Test("07-refs-circular")
    func refscircular() async throws {
        guard case let .object(yaml) = try fixtureMap("07-refs-circular", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"07-refs-circular", documentLoader: YamsDocumentLoader())
        guard case let .object(nodeObjectComponent) = try #require(apiSpec.components?.schemas?.first).element.type else { Issue.record(); return }
        #expect(nodeObjectComponent.properties.count == 1)
        #expect(nodeObjectComponent.properties.first?.key == "next")
    }
    
    @Test("08-oneof")
    func oneofanyof() async throws {
        guard case let .object(yaml) = try fixtureMap("08-oneof", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"08-oneof", documentLoader: YamsDocumentLoader())
        guard case let .oneOf(oneOf) = try #require(apiSpec[path: "/shape"]?.operations[operationID : "createShape"]?.requestBody?.contents[ key: "application/json"]?.schema?.type ) else { Issue.record(); return }
        #expect(oneOf.items?.count == 2)
        
    }
    
    @Test("08a-allof")
    func oneofallof() async throws {
        guard case let .object(yaml) = try fixtureMap("08a-allof", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"08a-allof", documentLoader: YamsDocumentLoader())
        guard case let .allOf(allOf) = try #require(apiSpec[path: "/shape"]?.operations[operationID : "createShape"]?.requestBody?.contents[ key: "application/json"]?.schema?.type ) else { Issue.record(); return }
        #expect(allOf.items?.count == 2)
        
        
    }
    
    @Test("09-enums-defaults-constraints")
    func enumsdefaultsconstraints() async throws {
        guard case let .object(yaml) = try fixtureMap("09-enums-defaults-constraints", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"09-enums-defaults-constraints", documentLoader: YamsDocumentLoader())
        guard case let .object(object) = try #require(apiSpec[path: "/order"]?.operations[operationID : "createOrder"]?.requestBody?.contents[ key: "application/json"]?.schema?.type ) else { Issue.record(); return }
        #expect(object.required.contains( "status"))
        #expect(object.required.contains( "count"))
        #expect(object.properties.contains(where: {$0.key ==  "count"}) )
        #expect(object.properties.contains(where: {$0.key == "status"}))
        #expect(object.properties.contains(where: {$0.key == "note"}))
        let schema = try #require(object.properties.first(where: { $0.key == "note" }))
        //guard case let  .string(noteProperty) = try #require(schema.type) else { Issue.record(); return }
        #expect(schema.element.pattern == "^[A-Z]+$")
    }
    @Test("10-servers-variables")
    func serversvariables() async throws {
        guard case let .object(yaml) = try fixtureMap("10-servers-variables", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"10-servers-variables", documentLoader: YamsDocumentLoader())
        #expect(apiSpec.servers.count == 6)
        //Änderungen an der Yaml-Datei
        let regionServer = try #require(apiSpec.servers[url: "https://{region}.api.example.com/{basePath}"])
        let regionVariable = try #require(regionServer.variables[key: "region"])
        #expect(regionVariable.defaultValue == "eu")
        #expect(regionVariable.enumList == ["eu", "us"])
        let baseVariable = try #require(apiSpec.servers.first?.variables[key: "basePath"])
        #expect(baseVariable.defaultValue == "v1")
        let selfurlServer =  try #require(apiSpec.servers[url: "."])
        #expect(selfurlServer.description == "The production API on this device")
        
        let stagingServer =  try #require(apiSpec.servers[url: "https://staging.gigantic-server.com/v1"])
        #expect(stagingServer.name == "staging")
        
        let prodServer =  try #require(apiSpec.servers[url: "https://{username}.gigantic-server.com:{port}/{basePath}"])
        #expect(prodServer.name == "prod")
        let prodServerPortVariable = try #require(prodServer.variables[key: "port"])
        #expect(prodServerPortVariable.defaultValue == "8443")
        #expect(prodServerPortVariable.enumList == ["8443","443"])
        
    }
    @Test("11-contenttype-vendor-json")
    func contenttypevendor() async throws {
        guard case let .object(yaml) = try fixtureMap("11-contenttype-vendor-json", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"11-contenttype-vendor-json", documentLoader: YamsDocumentLoader())
        #expect(apiSpec[path: "/fail"]?.operations[key: "get"]?.responses[key: "400"]?.content[key: "application/problem+json"]?.schema != nil)
    }
    @Test("20-webhook-minimal")
    func minimumwebhook() async throws {
        guard case let .object(yaml) = try fixtureMap("20-webhook-minimal", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"20-webhook-minimal", documentLoader: YamsDocumentLoader())
        let pingWebhook = try #require(apiSpec[webhook: "pingEvent"])
        let postMethod = try #require(pingWebhook[httpMethod: "post"].first)
        #expect(postMethod.key == "post")
        let postOperation = try #require(pingWebhook[operationId: "onPing"].first)
        #expect(postOperation.key == "post")
    }
    @Test("21-webhooks-multiple")
    func multiplewebhooks() async throws {
        guard case let .object(yaml) = try fixtureMap("21-webhooks-multiple", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml,url:"21-webhooks-multiple", documentLoader: YamsDocumentLoader())
        let orderCreatedWebhook = try #require(apiSpec[webhook: "orderCreated"])
        #expect(orderCreatedWebhook.operations.count == 1)
        #expect(orderCreatedWebhook.operations.first?.summary == "Triggered when a new order is created")
        let requiredBody = try #require(orderCreatedWebhook.operations.first?.requestBody)
        #expect(requiredBody.required == true)
        let orderCancelledWebhook = try #require(apiSpec[webhook:  "orderCancelled"])
        #expect(orderCancelledWebhook.operations.count == 1)
    }
    @Test("21-components")
    func nestedcomponents() async throws {
        guard case let .object(yaml) = try fixtureMap("21-webhooks-multiple", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"21-webhooks-multiple", documentLoader: YamsDocumentLoader())
        let orderCreatedEventComponent = try #require(apiSpec[schemacomponent: "Money"])
        guard case let .object(object) = try #require(orderCreatedEventComponent.element.type) else {
            Issue.record("Expected to extract an object schema from the Money component")
            return
        }
        #expect(object.properties.contains(where :{$0.key == "currency"}))
        let currencyInfo = try #require(object.properties.first(where: { $0.key == "currency" }))
        let schema = currencyInfo.element
        guard case .string = try #require(currencyInfo.element.type) else {
            Issue.record("Expected to extract a string schema for the 'currency' property")
            return
        }
        
        #expect(schema.minLength == 3)
        #expect(schema.maxLength == 3)
    }
    @Test("21-allofcomponents")
    func nestedallofcomponent() async throws {
        guard case let .object(yaml) = try fixtureMap("21-webhooks-multiple", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"21-webhooks-multiple", documentLoader: YamsDocumentLoader())
        let orderCreatedEventComponent = try #require(apiSpec[schemacomponent: "OrderCreatedEvent"])
        guard case .allOf = orderCreatedEventComponent.element.type else {
            Issue.record("Expected to extract an allOf schema for the OrderCreatedEvent component")
            return
        }
    }
    @Test("22-secured-webhooks")
    func securedwebhooks() async throws {
        guard case let .object(yaml) = try fixtureMap("22-secured-webhooks", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"22-secured-webhooks", documentLoader: YamsDocumentLoader())
        let webhookSignatureComponent = try #require(apiSpec[securityschemacomponent:  "webhookSignature"])
        #expect(webhookSignatureComponent.securityType == .apiKey)
        #expect(webhookSignatureComponent.location == .header)
        #expect(webhookSignatureComponent.location == .header)
        #expect(webhookSignatureComponent.name == "X-Signature")
        #expect(webhookSignatureComponent.description == "Shared-secret HMAC signature.")
    }
    
    @Test("23-oneOf-WebhookComponent")
    func oenOfsecurityWebhooks() async throws {
        guard case let .object(yaml) = try fixtureMap("23-oneOf-Webhooks", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"23-oneOf-Webhooks", documentLoader: YamsDocumentLoader())
        let schemaComponent = try #require(apiSpec[schemacomponent: "EventEnvelope"])
        guard case let .object(schemaComponentObject) = try #require(schemaComponent.element.type) else {
            Issue.record("Expected to extract an object schema for the EventEnvelope component")
            return
        }
        let payloadProperty = try #require(schemaComponentObject.properties.first(where: { $0.key == "payload" }))
        guard case let .oneOf(OneOfType) = payloadProperty.element.type else {
            Issue.record("Expected to extract an oneOf schema for the payload property of the EventEnvelope component")
            return
        }
        
        
        #expect(payloadProperty.element.discriminator?.mapping.count == 2)
        #expect(payloadProperty.element.discriminator?.propertyName == "type")
        #expect(payloadProperty.element.discriminator?.mapping["user.created"] == "#/components/schemas/UserCreated")
        #expect(payloadProperty.element.discriminator?.mapping["user.deleted"] == "#/components/schemas/UserDeleted")
        
        
    }
    @Test("30-externaldocs-tags")
    func externaldocstags() async throws {
        guard case let .object(yaml) = try fixtureMap("30-externaldocs-tags", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"30-externaldocs-tags", documentLoader: YamsDocumentLoader())
        #expect(apiSpec.externalDocumentation?.description == "Full developer documentation")
        #expect(apiSpec.externalDocumentation?.url == "https://docs.example.com/payments")
        let paymentsTag = try #require(apiSpec.tags[name: "payments"])
        #expect(paymentsTag.description == "Payment initiation and management")
        #expect(paymentsTag.externalDocs?.description ==  "Payments guide")
        #expect(paymentsTag.externalDocs?.url ==  "https://docs.example.com/payments/guide")
        let refundsTag = try #require(apiSpec.tags[name: "refunds"])
        #expect(refundsTag.description == "Refund lifecycle")
        #expect(refundsTag.externalDocs?.description ==  "Refunds guide")
        #expect(refundsTag.externalDocs?.url ==  "https://docs.example.com/refunds")
        #expect(apiSpec.paths[key:"/payments"]?.operations[operationID: "createPayment"]?.externalDocs?.description == "More details about payment creation")
        #expect(apiSpec.paths[key:"/payments"]?.operations[operationID: "createPayment"]?.externalDocs?.url == "https://docs.example.com/payments/create")
        #expect(apiSpec.paths[key:"/payments"]?.operations[operationID: "createPayment"]?.tags == ["payments"])
    }
    
    @Test("31-extensions-01")
    func extensions() async throws {
        guard case let .object(yaml) = try fixtureMap("31-extensions-01", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"31-extensions-01", documentLoader: YamsDocumentLoader())
        #expect( apiSpec.extensions?.count == 1)
        let xrootFlagsExtension = try #require(apiSpec.extensions?.first)
        guard case let .object(xrootFlagsObject) = xrootFlagsExtension.value else {
            Issue.record("object(xrootFlagsObject) expected")
            return
        }
    
        #expect(xrootFlagsObject.count == 2)
        #expect(
            xrootFlagsObject["featureToggle"] == .boolean(true),
            "boolean true expected"
        )
        let infoExtensions = try #require(apiSpec.info?.extensions)
        guard case let .object(infoExtensionObject) = infoExtensions.first?.value else {
            Issue.record("object(xrootFlagsObject) expected")
            return
        }
        #expect(infoExtensionObject.count == 3)
        #expect(infoExtensionObject["ownerTeam"] == .string("platform"))
        #expect(infoExtensionObject["lifecycle"] == .string("experimental"))
        #expect(infoExtensionObject["lastReviewed"] == .string("2025-10-01"))
    
        #expect(apiSpec.servers.count == 1)
        let serverextensions = try #require(apiSpec.servers.first?.extensions)
        #expect(serverextensions.count == 2)
        #expect(serverextensions[extensionName: "x-server-region"]?.value  == .string("eu-central-1"))
        #expect(serverextensions[extensionName: "x-server-weight"]?.value  == .integer(100))
        let tagextensions = try #require(apiSpec.tags.first?.extensions)
        #expect(tagextensions.count == 2)
        #expect(tagextensions[extensionName: "x-tag-color"]?.value == .string("#FF9900"))
        let xTagDocsExtensions = try #require(tagextensions[extensionName: "x-tag-docs"]?.value)
        
        guard case let .object(xTagDocExtensionObject) = xTagDocsExtensions else {
            Issue.record("object(tagExtensionObject) expected")
            return
        }
        #expect(xTagDocExtensionObject.count == 2)
        #expect(xTagDocExtensionObject["tocOrder"] == .integer(1))
        #expect(xTagDocExtensionObject["showInSidebar"] ==  .boolean(true))

        let pingOpExtensions = try #require(apiSpec.paths[key: "/ping"]?.operations[operationID: "ping"]?.extensions)
        #expect(pingOpExtensions.count == 1)
//        #expect(pingOpExtensions[extensionName: "x-operation-rate-limit"]?.structuredExtension?.properties?.count == 2)
//        let pingOpExtensionsProperties = try #require(pingOpExtensions[extensionName: "x-operation-rate-limit"]?.structuredExtension?.properties)
//        #expect(pingOpExtensionsProperties["burst"] == "20")
//        #expect(pingOpExtensionsProperties["sustainedPerMin"] == "120")
//        let extendedParameter = try #require(apiSpec.paths[key: "/ping"]?.operations[operationID: "ping"]?.parameters.first(where: { $0.name == "verbose" }) )
//        #expect(extendedParameter.extensions?.count == 1)
//        #expect(extendedParameter.extensions?[extensionName:"x-parameter-source"]?.simpleExtensionValue == "internal")
//        let parameterSchema = try #require(extendedParameter.schema)
//        //#expect(parameterSchema.extensions?.count == 1)
        //let parameterStructuredExtensionProperties = try #require(parameterSchema.extensions?[extensionName: "x-schema-ui"]?.structuredExtension?.properties)
        //#expect(parameterStructuredExtensionProperties["widget"] == "toggle")
        //#expect(parameterStructuredExtensionProperties["defaultLabel"] == "Detailed response")
    }
   
    
    @Test("32-mergekeys")
    func mergekeys() async throws {
        
        guard case let .object(yaml) = try fixtureMap("32-mergekeys", subDirectory: "Resources/3_0/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"32-mergekeys", documentLoader: YamsDocumentLoader())
        let baseAnchorServer = try #require(apiSpec.servers[url: "."])
        #expect(baseAnchorServer.description == "The production API on this device")
        //#expect(baseAnchorServer.extensions?[extensionName: "x-timeout"]?.simpleExtensionValue == "30")
        //#expect(baseAnchorServer.extensions?[extensionName: "x-custom-header"]?.simpleExtensionValue == "value")
        
        let deviceServer = try #require(apiSpec.servers[url: "./test"])
        #expect(deviceServer.description == "The test API on this device")
        //#expect(deviceServer.extensions?[extensionName: "x-timeout"]?.simpleExtensionValue == "60")
        //#expect(deviceServer.extensions?[extensionName: "x-custom-header"]?.simpleExtensionValue == "value")
    }
    @Test("33-components-singlefile")
    func componentssinglefile() async throws {
        guard case let .object(yaml) = try fixtureMap("33-components-singlefile", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened:  yaml, url:"33-components-singlefile", documentLoader: YamsDocumentLoader())
        #expect(apiSpec.components?.schemas?.count == 2)
        
        #expect(apiSpec.components?.requestBodies?.count == 1)
        let requestBody = try #require(apiSpec.components?.requestBodies?[key: "CreateUserRequest"])
        #expect(requestBody.description == "JSON-Payload für das Anlegen eines Users")
        #expect(requestBody.required == true)
        
        #expect(apiSpec.components?.examples?.count == 1)
        let example = try #require(apiSpec.components?.examples?[key: "UserExample"])
        #expect(example.summary == "Beispiel-User")
        
        #expect(apiSpec.components?.links?.count == 1)
        let link = try #require(apiSpec.components?.links?[key: "GetUserById"])
        #expect(link.description == "Hole den gerade angelegten User")
        #expect(link.operationId == "getUser")
        #expect(link.parameters["userId"] == "$response.body#/id")
        
        #expect(apiSpec.components?.callbacks?.count == 1)
        let callback = try #require(apiSpec.components?.callbacks?[key:"UserCreatedCallback"]?.pathItems?[key: "{$request.body#/callbackUrl}"])
        #expect((callback.operations[operationID: "userCreatedCallbackReceiver"] != nil))
        #expect(callback.key == "{$request.body#/callbackUrl}")
        
        #expect(apiSpec.components?.pathItems?.count == 1)
        let pathItem = try #require(apiSpec.components?.pathItems?[key:"UserByIdPathItem"])
        #expect(pathItem.key == "UserByIdPathItem")
        #expect(pathItem.operations[operationID: "getUser"]?.summary == "Get user by id")
    }
    @Test("34-openapi-main")
    func componentsmultiplefile() async throws {
        guard case let .object(yaml) = try fixtureMap("34-openapi-main", subDirectory: "Resources/3_1/valid") else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"34-openapi-main", documentLoader: YamsDocumentLoader())
        let createUserRequest = try #require(apiSpec[requestbodycomponent: "CreateUserRequest"])
        
    }
    @Test("34-openapi-main resolvecomponents")
        func resolveComponents() async throws {
            guard case let .object(yaml) = try fixtureMap("34-openapi-main", subDirectory: "Resources/3_1/valid") else {
                Issue.record("Expected .object(let)")
                return
            }
            let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"34-openapi-main", documentLoader: YamsDocumentLoader())
        /*let component = try #require(apiSpec.element(for: "components") as? OpenAPIComponent)
        let requestBodyComponent = try #require(component.element(for: "requestBodies") as? [OpenAPIRequestBody])
            let createUserRequest = try #require(requestBodyComponent.element(for: "CreateUserRequest"))
         */
    }
    
}
