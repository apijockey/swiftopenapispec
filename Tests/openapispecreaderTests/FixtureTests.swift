//
//  Test.swift
//  openapispecreader
//
//  Created by Patric Dubois on 30.11.25.
//

import Foundation
import Testing
import Yams
import SwiftOpenAPISpec

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
    private func fixtureMap(_ resource: String, ext: String = "yaml") throws -> StringDictionary {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else {
            throw Self.Errors.notFound(name)
        }

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
            let yaml = try Yams.load(yaml: string) as? StringDictionary else {
                throw Self.Errors.notUTF8(name)
            }
            return yaml
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
   
    @Test("minimal-3_0/Parser-Happy-Path für 3.0.x.")
    func minimal() async throws {
        
        let yaml = try fixtureMap("minimal-3_0")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"minimal-3_0" , documentLoader: YamsDocumentLoader())
        #expect(apiSpec.version == "3.0.3")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping"].first)
        #expect(getPingOperation.responses?.count == 1)
    
    }
    @Test("02 3.1-Path, jsonSchema dialect, modernere Keywords „fit through“.")
    func modernKeywords() async throws {
        
        let yaml = try fixtureMap("02-minimal-31")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"02-minimal-31" , documentLoader: YamsDocumentLoader())
        #expect(apiSpec.version == "3.1.0")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping31"].first)
        #expect(getPingOperation.responses?.count == 1)
        let responses = try #require(getPingOperation.responses)
        #expect(responses.count == 1)
        let contentType = try #require(getPingOperation.response(httpstatus: "200")?.content[key: "application/json"])
        #expect(contentType.schema?.schemaType is OpenAPIObjectType)
        let getPing200Response = try #require(getPingOperation.response(httpstatus:  "200"))
        #expect(getPing200Response.content.count == 1)
        let getPingResponseContent = try #require(getPing200Response.content.first?.schema?.schemaType as? OpenAPIObjectType)
        #expect(getPingResponseContent.unevaluatedProperties == false)
        #expect(getPingResponseContent.properties.count == 1)
        #expect(getPingResponseContent.required.count == 1)
        #expect(getPingResponseContent.required.first! == "ok")
        
    }
    @Test("03-pathitems, parameter matrix, operations, additional operations")
    func pathitems() async throws {
        
        let yaml = try fixtureMap("03-pathitems")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"03-pathitems", documentLoader: YamsDocumentLoader())
        let path = try #require(apiSpec[path: "/pets/{id}"])
        #expect(path.description == "Returns pets information")
        #expect(path.summary == "get Pets")
        let parameters = try #require(path.operations[operationID : "getPet"]?.parameters)
        #expect(parameters.count == 1)
        let parameter = parameters.first!
        #expect(parameter.key == "id")
        #expect(parameter.location == SwiftOpenAPISpec.OpenAPIParameter.ParameterLocation.path)
        #expect(parameter.schema?.schemaType is OpenAPIStringType)
        #expect(parameter.explode == nil)
        #expect(parameter.deprecated == nil)

        let searchPath = try #require(apiSpec[path: "/pets"])
        let searchParameters = try #require(searchPath.operations[operationID : "searchPets"]?.parameters)
        let copyOperation = try #require(searchPath.additionalOperations[operationID : "copyPetsById"])
        
        
        #expect(parameters.count == 1)
        let queryParameter = searchParameters.first!
        #expect(queryParameter.key == "limit")
        #expect(queryParameter.location == OpenAPIParameter.ParameterLocation.query)
        let parameterType = try #require(queryParameter.schema?.schemaType as? OpenAPIIntegerType)
        #expect(parameterType.defaultValue == 10)
        #expect(parameterType.minimum == 1)
        #expect(parameterType.maximum == 100)
        
    }
    
    @Test("04-requestbody-media-types")
    func mediatypes() async throws {
        
        let yaml = try fixtureMap("04-requestbody-media-types")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"04-requestbody-media-types", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 2)
        
    }
    
    @Test("04a-requestbody-media-types-enum")
    func enumtypes() async throws {
        
        let yaml = try fixtureMap("04a-requestbody-media-types-enum")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"04a-requestbody-media-types-enum", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 1)
        let stringType = try #require(requestbodyContents[0].schema?.schemaType as? OpenAPIStringType)
        #expect(stringType.allowedElements == ["Alice","Bob","Carl"])
        
        
    }
    
    @Test("04b-requestbody-media-types-object")
    func arraytypes() async throws {
        
        let yaml = try fixtureMap("04b-requestbody-media-types-object")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"04b-requestbody-media-types-object", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/upload"]?.operations)
        #expect(operations.count == 1)
        
        let requestbodyContents = try #require(apiSpec[path: "/upload"]?.operations[operationID : "upload"]?.requestBody?.contents)
        #expect(requestbodyContents.count == 1)
        let objectType = try #require(requestbodyContents[0].schema?.schemaType as? OpenAPIObjectType)
        #expect(objectType.properties.count == 2)
        #expect(objectType.properties.contains(where:{$0.key == "productName"}))
        #expect(objectType.properties.contains(where:{$0.key == "productPrice"}))
        #expect(objectType.properties[key: "productName"]?.type is OpenAPIStringType)
        #expect(objectType.properties[key: "productPrice"]?.type is  OpenAPIDoubleType)
        
        
    }
    
    @Test("05-responses-status-default")
    func components() async throws {
        
        let yaml = try fixtureMap("05-responses-status-default")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"05-responses-status-default", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/create"]?.operations)
        #expect(operations.count == 1)
        
        let response201 = try #require(apiSpec[path: "/create"]?.operations[operationID : "create"]?.response(httpstatus: "201"))
        #expect(response201.description == "created")
        #expect((response201.content.first?.schema?.schemaType as? OpenAPIObjectType)?.required.first  == "id")
        #expect((response201.content.first?.schema?.schemaType as? OpenAPIObjectType)?.required.count  == 1)
        let defaultResponse = try #require(apiSpec[path: "/create"]?.operations[operationID : "create"]?.response(httpstatus: "default"))
        #expect(defaultResponse.description == "error")
        let component = try #require(defaultResponse.content.first?.schema?.ref as? OpenAPISchemaReference)
        #expect(component.reference == "#/components/schemas/Error")
    }
    
    @Test("tictactor-nested-array-elements")
    func nestedArrayElements() async throws {
        let yaml = try fixtureMap("tictactoe")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"tictactoe", documentLoader: YamsDocumentLoader())
        let operations = try #require(apiSpec[path: "/board"]?.operations)
        #expect(operations.count == 1)
        #expect(operations.first?.response(httpstatus: "200")?.content.count == 1)
        let objectType = try #require(operations.first?.response(httpstatus: "200")?.content.first?.schema?.schemaType as? OpenAPIObjectType)
        #expect(objectType.properties.count == 2)
        let winnerProperty = try #require(objectType.properties[key: "winner"])
        let stringPropertyInfo = try #require(winnerProperty.type as? OpenAPIStringType )
        #expect(stringPropertyInfo.allowedElements == ["X", "O", "."])
        let boardProperty = try #require((objectType.properties[key: "board"]?.type as? OpenAPIArrayType))
        #expect(boardProperty.maxItems == 3)
        #expect(boardProperty.minItems == 3)
        let boardSubItems = try #require(boardProperty.items as? OpenAPIArrayType)
        #expect(boardSubItems.items is OpenAPIStringType)
        
    }
    
    @Test("07-refs-circular")
    func refscircular() async throws {
        let yaml = try fixtureMap("07-refs-circular")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"07-refs-circular", documentLoader: YamsDocumentLoader())
        let nodeObjectComponent = try #require(apiSpec.components?.schemas?.first?.schemaType as? OpenAPIObjectType)
        #expect(nodeObjectComponent.properties.count == 1)
        #expect(nodeObjectComponent.properties.first?.key == "next")
    }
    
    @Test("08-oneof")
    func oneofanyof() async throws {
        let yaml = try fixtureMap("08-oneof")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"08-oneof", documentLoader: YamsDocumentLoader())
        let oneOf = try #require(apiSpec[path: "/shape"]?.operations[operationID : "createShape"]?.requestBody?.contents[ key: "application/json"]?.schema?.schemaType as? OpenAPIOneOfType)
        #expect(oneOf.items?.count == 2)
        
    }
    
    @Test("08a-allof")
    func oneofallof() async throws {
        let yaml = try fixtureMap("08a-allof")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"08a-allof", documentLoader: YamsDocumentLoader())
        let allOf = try #require(apiSpec[path: "/shape"]?.operations[operationID : "createShape"]?.requestBody?.contents[ key: "application/json"]?.schema?.schemaType as? OpenAPIAllOfType)
        #expect(allOf.items?.count == 2)
        
        
    }
    
    @Test("09-enums-defaults-constraints")
    func enumsdefaultsconstraints() async throws {
        let yaml = try fixtureMap("09-enums-defaults-constraints")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"09-enums-defaults-constraints", documentLoader: YamsDocumentLoader())
        let object = try #require(apiSpec[path: "/order"]?.operations[operationID : "createOrder"]?.requestBody?.contents[ key: "application/json"]?.schema?.schemaType as? OpenAPIObjectType)
        #expect(object.required.contains( "status"))
        #expect(object.required.contains( "count"))
        #expect(object.properties.contains(name: "count"))
        #expect(object.properties.contains(name: "status"))
        #expect(object.properties.contains(name: "note"))
        let noteProperty = try #require(object.properties[key: "note"]?.type as? OpenAPIStringType)
        #expect(noteProperty.pattern == "^[A-Z]+$")
    }
    @Test("10-servers-variables")
    func serversvariables() async throws {
        let yaml = try fixtureMap("10-servers-variables")
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
        let yaml = try fixtureMap("11-contenttype-vendor-json")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"11-contenttype-vendor-json", documentLoader: YamsDocumentLoader())
        #expect(apiSpec[path: "/fail"]?.operations[key: "get"]?.responses?[key: "400"]?.content[key: "application/problem+json"]?.schema?.schemaType is OpenAPIObjectType)
    }
    @Test("20-webhook-minimal")
    func minimumwebhook() async throws {
        let yaml = try fixtureMap("20-webhook-minimal")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"20-webhook-minimal", documentLoader: YamsDocumentLoader())
        let pingWebhook = try #require(apiSpec[webhook: "pingEvent"])
        let postMethod = try #require(pingWebhook[httpMethod: "post"].first)
        #expect(postMethod.key == "post")
        let postOperation = try #require(pingWebhook[operationId: "onPing"].first)
        #expect(postOperation.key == "post")
    }
    @Test("21-webhooks-multiple")
    func multiplewebhooks() async throws {
        let yaml = try fixtureMap("21-webhooks-multiple")
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
        let yaml = try fixtureMap("21-webhooks-multiple")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"21-webhooks-multiple", documentLoader: YamsDocumentLoader())
        let orderCreatedEventComponent = try #require(apiSpec[schemacomponent: "Money"])
        let object = try #require(orderCreatedEventComponent.schemaType as? OpenAPIObjectType)
        #expect(object.properties.contains(name:"currency"))
        let currencyInfo = try #require(object.properties[key:"currency"])
        let currencyTypeInfo = try #require(currencyInfo.type as? OpenAPIStringType)
        #expect(currencyTypeInfo.minLength == 3)
        #expect(currencyTypeInfo.maxLength == 3)
    }
    @Test("21-allofcomponents")
    func nestedallofcomponent() async throws {
        let yaml = try fixtureMap("21-webhooks-multiple")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"21-webhooks-multiple", documentLoader: YamsDocumentLoader())
        let orderCreatedEventComponent = try #require(apiSpec[schemacomponent: "OrderCreatedEvent"])
        #expect(orderCreatedEventComponent.schemaType is OpenAPIAllOfType)
    }
    @Test("22-secured-webhooks")
    func securedwebhooks() async throws {
        let yaml = try fixtureMap("22-secured-webhooks")
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
        let yaml = try fixtureMap("23-oneOf-Webhooks")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"23-oneOf-Webhooks", documentLoader: YamsDocumentLoader())
        let schemaComponent = try #require(apiSpec[schemacomponent: "EventEnvelope"])
        let schemaComponentObject = try #require(schemaComponent.schemaType as? OpenAPIObjectType)
        let payloadProperty = try #require(schemaComponentObject.properties[key: "payload"])
        #expect(payloadProperty.type is OpenAPIOneOfType)
        let discriminator = try #require(payloadProperty.discriminator)
        #expect(discriminator.propertyName == "type")
        #expect(discriminator.mapping?.count == 2)
        #expect(discriminator.mapping?["user.created"] == "#/components/schemas/UserCreated")
        #expect(discriminator.mapping?["user.deleted"] == "#/components/schemas/UserDeleted")
        
        
    }
    @Test("30-externaldocs-tags")
    func externaldocstags() async throws {
        let yaml = try fixtureMap("30-externaldocs-tags")
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
        let yaml = try fixtureMap("31-extensions-01")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"31-extensions-01", documentLoader: YamsDocumentLoader())
        #expect( apiSpec.extensions?.count == 1)
        #expect(apiSpec.extensions?[extensionName: "x-root-flags"]?.structuredExtension?.properties?.count == 2)
        #expect(apiSpec.info?.extensions?.count == 1)
        let properties = try #require(apiSpec.info?.extensions?[extensionName:"x-info-meta"]?.structuredExtension?.properties)
        #expect(properties.containsKey("ownerTeam"))
        #expect(properties.containsKey("lifecycle"))
        #expect(properties.containsKey("lastReviewed"))
        #expect(apiSpec.servers.count == 1)
        let serverextensions = try #require(apiSpec.servers.first?.extensions)
        #expect(serverextensions.count == 2)
        #expect(serverextensions[extensionName: "x-server-region"]?.simpleExtensionValue == "eu-central-1")
        #expect(serverextensions[extensionName: "x-server-weight"]?.simpleExtensionValue == "100")
        let tagextensions = try #require(apiSpec.tags.first?.extensions)
        #expect(tagextensions.count == 2)
        #expect(tagextensions[extensionName: "x-tag-color"]?.simpleExtensionValue == "#FF9900")
        let tagDocsExtensionProperties = try #require(tagextensions[extensionName: "x-tag-docs"]?.structuredExtension?.properties)
        #expect(tagDocsExtensionProperties.count == 2)
        #expect(tagDocsExtensionProperties["tocOrder"] == "1")
        #expect(tagDocsExtensionProperties["showInSidebar"] == "true")
        
        let pingOpExtensions = try #require(apiSpec.paths[key: "/ping"]?.operations[operationID: "ping"]?.extensions)
        #expect(pingOpExtensions.count == 1)
        #expect(pingOpExtensions[extensionName: "x-operation-rate-limit"]?.structuredExtension?.properties?.count == 2)
        let pingOpExtensionsProperties = try #require(pingOpExtensions[extensionName: "x-operation-rate-limit"]?.structuredExtension?.properties)
        #expect(pingOpExtensionsProperties["burst"] == "20")
        #expect(pingOpExtensionsProperties["sustainedPerMin"] == "120")
        let extendedParameter = try #require(apiSpec.paths[key: "/ping"]?.operations[operationID: "ping"]?.parameters?[key: "verbose"])
        #expect(extendedParameter.extensions?.count == 1)
        #expect(extendedParameter.extensions?[extensionName:"x-parameter-source"]?.simpleExtensionValue == "internal")
        let parameterSchema = try #require(extendedParameter.schema)
        #expect(parameterSchema.extensions?.count == 1)
        let parameterStructuredExtensionProperties = try #require(parameterSchema.extensions?[extensionName: "x-schema-ui"]?.structuredExtension?.properties)
        #expect(parameterStructuredExtensionProperties["widget"] == "toggle")
        #expect(parameterStructuredExtensionProperties["defaultLabel"] == "Detailed response")
    }
   
    
    @Test("32-mergekeys")
    func mergekeys() async throws {
        let yaml = try fixtureMap("32-mergekeys")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"32-mergekeys", documentLoader: YamsDocumentLoader())
        let baseAnchorServer = try #require(apiSpec.servers[url: "."])
        #expect(baseAnchorServer.description == "The production API on this device")
        #expect(baseAnchorServer.extensions?[extensionName: "x-timeout"]?.simpleExtensionValue == "30")
        #expect(baseAnchorServer.extensions?[extensionName: "x-custom-header"]?.simpleExtensionValue == "value")
        
        let deviceServer = try #require(apiSpec.servers[url: "./test"])
        #expect(deviceServer.description == "The test API on this device")
        #expect(deviceServer.extensions?[extensionName: "x-timeout"]?.simpleExtensionValue == "60")
        #expect(deviceServer.extensions?[extensionName: "x-custom-header"]?.simpleExtensionValue == "value")
    }
    @Test("33-components-singlefile")
    func componentssinglefile() async throws {
        let yaml = try fixtureMap("33-components-singlefile")
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
        let yaml = try fixtureMap("34-openapi-main")
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"34-openapi-main", documentLoader: YamsDocumentLoader())
        let createUserRequest = try #require(apiSpec[requestbodycomponent: "CreateUserRequest"])
        
    }
    @Test("34-openapi-main resolvecomponents")
        func resolveComponents() async throws {
        let yaml = try fixtureMap("34-openapi-main")
            let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:"34-openapi-main", documentLoader: YamsDocumentLoader())
        let component = try #require(apiSpec.element(for: "components") as? OpenAPIComponent)
        let requestBodyComponent = try #require(component.element(for: "requestBodies") as? [OpenAPIRequestBody])
            let createUserRequest = try #require(requestBodyComponent.element(for: "CreateUserRequest"))
    }
    
}
