import Testing
import Yams
import Foundation
@testable import SwiftOpenAPISpec

@Suite("OpenAPI Spec (legacy XCTest -> Swift Testing)")
struct OpenAPILegacyPortedTests {

    @Test
    func testBasics() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml")
            return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.version == "3.1.0")
        #expect(apiSpec.info.title == "GreetingService")
        #expect(apiSpec.info.version == "1.0.0")
        #expect(apiSpec.info.summary == "Prints a greeting on GET request")
        #expect(apiSpec.info.termsOfService == "Displayss the terms of services")
        #expect((apiSpec.info.contact?.name ?? "") == "API Support")
        #expect((apiSpec.info.contact?.url ?? "") == "https://www.example.com/support")
        #expect((apiSpec.info.contact?.email ?? "") == "support@example.com")
        #expect((apiSpec.info.license?.name ?? "") == "Apache 2.0")
        #expect((apiSpec.info.license?.url ?? "") == "https://www.apache.org/licenses/LICENSE-2.0.html")
    }

    @Test
    func testServers() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.servers.count == 3)
        #expect(apiSpec.servers[0].url == "https://example.com/api")
        #expect(apiSpec.servers[0].description == "Example service deployment.")
        #expect(apiSpec.servers[1].url == "http://127.0.0.1:8080/api")
        #expect(apiSpec.servers[1].description == "Localhost deployment.")
        #expect(apiSpec.servers[2].variables.count == 3)

        guard let usernameVariable = apiSpec.servers[2].variables.first(where: { $0.key == "username" }) else {
            #expect(Bool(false), "no username variable"); return
        }
        #expect(usernameVariable.defaultValue == "demo")
        #expect(usernameVariable.description == "this value is assigned by the service provider, in this example `gigantic-server.com`")
        #expect(usernameVariable.enumList == nil)

        guard let portVariable = apiSpec.servers[2].variables.first(where: { $0.key == "port" }) else {
            #expect(Bool(false), "no port variable"); return
        }
        #expect(portVariable.defaultValue == "8443")
        #expect(portVariable.enumList?.count == 2)
        #expect(portVariable.enumList?.contains("8443") == true)
        #expect(portVariable.enumList?.contains("443") == true)
    }

    @Test
    func testPathInfo() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.paths.count == 4)

        let getGreetPath = try #require(apiSpec.paths.first { $0.key == "/greet" })
        #expect(getGreetPath.operations.count == 1)
        let getEmojiPath = try #require(apiSpec.paths.first { $0.key == "/emoji" })
        let getClipPath = try #require(apiSpec.paths.first { $0.key == "/clip" })
        #expect(getGreetPath.operations.count == 1)
        #expect(getEmojiPath.operations.count == 1)
        #expect(getClipPath.operations.count == 1)

        let emojiPathOperation = try #require(getEmojiPath.operations.first)
        #expect(emojiPathOperation.responses?.count == 1)
        #expect(emojiPathOperation.key == "get")

        let clipPathOperation = try #require(getClipPath.operations.first)
        #expect(clipPathOperation.key == "get")

        let greetingPathOperation = try #require(getGreetPath.operations.first)
        #expect(greetingPathOperation.key == "get")
    }

    @Test
    func testOperations() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        let getClipPath = try #require(apiSpec.paths.first { $0.key == "/clip" })
        let clipPathOperation = try #require(getClipPath.operations.first)
        #expect(clipPathOperation.key == "get")
        #expect(clipPathOperation.responses?.count == 1)
        #expect(clipPathOperation.operationId == "getClip")
        let response  = try #require(clipPathOperation.responses?.first)
        #expect(response.description == "Returns a cat video! 😽")
        #expect(response.key == "200")
    }

    @Test
    func testParameters() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        let getGreetPath = try #require(apiSpec.paths.first { $0.key == "/greet" })
        let getEmojiPath = try #require(apiSpec.paths.first { $0.key == "/emoji" })
        let getClipPath = try #require(apiSpec.paths.first { $0.key == "/clip" })
        let clipPathOperation = try #require(getClipPath.operations.first)
        let emojiPathOperation = try #require(getEmojiPath.operations.first)
        let greetPathOperation = try #require(getGreetPath.operations.first)
        #expect(clipPathOperation.parameters?.count == 0)
        #expect(emojiPathOperation.parameters?.count == 0)
        #expect(greetPathOperation.parameters?.count == 1)
        let greetPathParameter = try #require(greetPathOperation.parameters?.first)
        #expect(greetPathParameter.key == "name")
        #expect(greetPathParameter.required == false)
        #expect(greetPathParameter.location == OpenAPIParameter.ParameterLocation.query)
        #expect(greetPathParameter.description == "The name used in the returned greeting.")
        #expect(greetPathParameter.schema?.schemaType is OpenAPIStringType)
        #expect(greetPathParameter.allowEmptyValue == nil)
    }

    @Test
    func testResponses() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        let getGreetPath = try #require(apiSpec.paths.first { $0.key == "/greet" })
        let greetPathOperation = try #require(getGreetPath.operations.first)
        let response = try #require(greetPathOperation.responses?.first)
        #expect(response.key == "200")
        #expect(response.content.count == 1)
        let content = try #require(response.content.first)
        #expect(content.key == "application/json")
        #expect(content.schema?.ref?.reference == "#/components/schemas/Greeting")
    }

    @Test
    func testSchemaComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.components?.schemas?.count == 4)
        let greetingComponent = try #require(apiSpec.components?.schemas?.first { $0.key == "Greeting" })
        let greetingObject = try #require(greetingComponent.schemaType as? OpenAPIObjectType)
        #expect(greetingObject.properties.count == 1)
        let messageProperty = try #require(greetingObject.properties.first)
        #expect(messageProperty.type is OpenAPIStringType)
        #expect(greetingObject.required == ["message"])

        let generalErrorComponent = try #require(apiSpec[schemacomponent: "GeneralError"])
        let errorObject = try #require(generalErrorComponent.schemaType as? OpenAPIObjectType)
        #expect(errorObject.properties.count == 2)
        let errorMessageCodeProperty = errorObject.properties[key: "code"]
        #expect(errorMessageCodeProperty?.type is OpenAPIIntegerType)
        let errorMessageMessageProperty = errorObject.properties[key: "message"]
        #expect(errorMessageMessageProperty?.type is OpenAPIStringType)
        #expect(errorObject.required.count == 0)
    }

    @Test
    func testParameterComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.components?.parameters?.count == 2)
        let skipParamComponent = try #require(apiSpec[parametercomponent: "skipParam"])
        #expect(skipParamComponent.key == "skipParam")
        #expect(skipParamComponent.location == OpenAPIParameter.ParameterLocation.query)
        #expect(skipParamComponent.description == "number of items to skip")
        #expect(skipParamComponent.required == true)
        #expect(skipParamComponent.schema?.schemaType is OpenAPIIntegerType)
    }

    @Test
    func testResponsesComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.components?.responses?.count == 4)

        let notFoundResponse = try #require(apiSpec.components?.responses?.first(where: { $0.key == "NotFound" }))
        #expect(notFoundResponse.description == "Entity not found.")

        let imageResponse = try #require(apiSpec.components?.responses?.first(where: { $0.key == "ImageResponse" }))
        #expect(imageResponse.description == "An image.")

        let illegalInput = try #require(apiSpec.components?.responses?.first(where: { $0.key == "IllegalInput" }))
        #expect(illegalInput.description == "Illegal input for operation.")

        let generalError = try #require(apiSpec.components?.responses?.first(where: { $0.key == "GeneralError" }))
        #expect(generalError.description == "General Error")
        #expect(generalError.content.count == 1)
        let jsonContent = try #require(generalError.content.first { $0.key == "application/json" })
        #expect(jsonContent.schema?.ref?.reference == "#/components/schemas/GeneralError")
    }

    @Test
    func testRequestBody() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.paths.count == 4)
        let getPetsPath = try #require(apiSpec.paths.first { $0.key == "/pets" })
        let postOperation = try #require(getPetsPath.operations.first { $0.key == "post" })
        #expect(postOperation.requestBody?.description == "Optional description in *Markdown*")
        #expect(postOperation.requestBody?.required == true)
        #expect(postOperation.requestBody?.contents.count == 4)
    }

    @Test
    func testOneOfSchema() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.paths.count == 4)
        let getPetsPath = try #require(apiSpec.paths.first { $0.key == "/pets" })
        #expect(getPetsPath.operations.count == 3)
        let patchOperation = try #require(getPetsPath.operations.first { $0.key == "patch" })
        #expect(patchOperation.requestBody?.required == false)
        let jsonContent = try #require(patchOperation.requestBody?.contents.first(where: { $0.key == "application/json" }))
        let oneOfSchemas = try #require(jsonContent.schema?.schemaType as? OpenAPIOneOfType)
        #expect(oneOfSchemas.items?.count == 2)
    }

    @Test
    func testOperationSecurityScheme() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.paths.count == 4)
        let getGreetPath = try #require(apiSpec.paths.first { $0.key == "/greet" })
        let getOperation = try #require(getGreetPath.operations.first { $0.key == "get" })
        #expect(getOperation.securityObjects.count == 2)
        let petStoreAuth = try #require(getOperation.securityObjects.first { $0.key == "petstore_auth" })
        #expect(petStoreAuth.scopes.contains("write:pets"))
        #expect(petStoreAuth.scopes.contains("read:pets"))
        let clipStoreAuth = try #require(getOperation.securityObjects.first { $0.key == "clip_auth" })
        #expect(clipStoreAuth.scopes.contains("write:clips"))
        #expect(clipStoreAuth.scopes.contains("read:clips"))
    }

    @Test
    func testSecurityComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.components?.securitySchemas?.count == 5)

        let httpKeySecurityScheme = try #require(apiSpec.components?.securitySchemas?.first{ $0.key == "http_Key"})
        #expect(httpKeySecurityScheme.securityType == .http)
        #expect(httpKeySecurityScheme.httpScheme == "basic")

        let apiKeySecurityScheme = try #require(apiSpec.components?.securitySchemas?.first{ $0.key == "api_key"})
        #expect(apiKeySecurityScheme.securityType == .apiKey)
        #expect(apiKeySecurityScheme.name == "api_key")
        #expect(apiKeySecurityScheme.location == .header)

        let bearerKeySecurityScheme = try #require(apiSpec.components?.securitySchemas?.first{ $0.key == "bearer_key"})
        #expect(bearerKeySecurityScheme.securityType == .http)
        #expect(bearerKeySecurityScheme.httpScheme == "bearer")
        #expect(bearerKeySecurityScheme.httpBearerFormat == "JWT")

        let petStoreOAuth2KeySecurityScheme = try #require(apiSpec.components?.securitySchemas?.first{ $0.key == "petstore_auth"})
        #expect(petStoreOAuth2KeySecurityScheme.securityType == .oauth2)
        #expect(petStoreOAuth2KeySecurityScheme.flows?.implicit != nil)
        let flowImplicit = try #require(petStoreOAuth2KeySecurityScheme.flows?.implicit)
        #expect(flowImplicit.authorizationUrl == "https://example.org/api/oauth/dialog")
        #expect(flowImplicit.scopes?.count == 2)
        #expect(flowImplicit.scopes?.contains(where: { k, _ in k == "write:pets" }) == true)
        #expect(flowImplicit.scopes?.contains(where: { k, _ in k == "read:pets" }) == true)

        let clipStoreOAuth2KeySecurityScheme = try #require(apiSpec.components?.securitySchemas?.first{ $0.key == "clip_auth"})
        #expect(clipStoreOAuth2KeySecurityScheme.securityType == .oauth2)
        #expect(clipStoreOAuth2KeySecurityScheme.flows?.implicit != nil)
        let clipflowImplicit = try #require(clipStoreOAuth2KeySecurityScheme.flows?.implicit)
        #expect(clipflowImplicit.authorizationUrl == "https://example.com/api/oauth/dialog")
        #expect(clipStoreOAuth2KeySecurityScheme.flows?.authorizationCode != nil)
        let clipflowAuthorizationCode = try #require(clipStoreOAuth2KeySecurityScheme.flows?.authorizationCode)
        #expect(clipflowAuthorizationCode.authorizationUrl == "https://example.com/api/oauth/dialog")
        #expect(clipflowAuthorizationCode.tokenUrl == "https://example.com/api/oauth/token")
        #expect(clipflowAuthorizationCode.scopes?.count == 2)
        #expect(clipflowAuthorizationCode.scopes?.contains(where: { k, _ in k == "write:clips" }) == true)
        #expect(clipflowAuthorizationCode.scopes?.contains(where: { k, _ in k == "read:clips" }) == true)
    }

    @Test
    func testExamples() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.paths.count == 4)
        let getPetsPath = try #require(apiSpec.paths.first { $0.key == "/pets" })
        #expect(getPetsPath.operations.count == 3)
        let postOperation = try #require(getPetsPath.operations.first { $0.key == "post" })
        let mediatype = try #require(postOperation.requestBody?.contents.first(where: { $0.key == "text/plain" }))
        #expect(mediatype.examples.count == 3)
        let userExample = mediatype.examples[key: "user"]
        #expect(userExample?.summary == "User example in Plain text")
        #expect(userExample?.externalValue == "https://foo.bar/examples/user-example.txt")
        let fooExample = mediatype.examples.first { $0.key == "foo"}
        #expect(fooExample?.summary == "A foo example")
        #expect(fooExample?.value != nil)
        let barExample = mediatype.examples.first { $0.key == "bar"}
        #expect(barExample?.summary == "A bar example")
        #expect(barExample?.value != nil)
    }

    @Test
    func testExamplesRef() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        #expect(apiSpec.paths.count == 4)
        let getPetsPath = try #require(apiSpec.paths.first { $0.key == "/pets" })
        #expect(getPetsPath.operations.count == 3)
        let patchOperation = try #require(getPetsPath.operations.first { $0.key == "patch" })
        let mediatype = try #require(patchOperation.requestBody?.contents.first(where: { $0.key == "application/json" }))
        #expect(mediatype.examples.count == 1)
        let refExample = try #require(mediatype.examples[key:"confirmation-success"])
        #expect(refExample.ref?.reference == "#/components/examples/confirmation-success")
    }

    @Test
    func testLinks() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            #expect(Bool(false), "no openapi"); return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            #expect(Bool(false), "no valid yaml"); return
        }
        let apiSpec = try OpenAPIObject.read(text: string, url: "openapi")
        let getPetsPath = try #require(apiSpec.paths.first { $0.key == "/pets" })
        let patchOperation = try #require(getPetsPath.operations.first { $0.key == "patch" })
        let links = try #require(patchOperation.responses?.first(where: { $0.key == "200" })?.links)
        #expect(links.count == 2)
        let addressLink = try #require(links.first { $0.key == "address" })
        #expect(addressLink.operationId == "getUserAddress")
        #expect(addressLink.parameters.count == 1)
        let parameter = addressLink.parameters.first { key, _ in key == "userId" }
        #expect(parameter?.value == "$request.path.id")
        let userRepositoriesLink = try #require(links.first { $0.key == "UserRepositories" })
        #expect(userRepositoriesLink.operationRef == "#/paths/~12.0~1repositories~1{username}/get")
        #expect(userRepositoriesLink.parameters.count == 1)
        let repParameter = userRepositoriesLink.parameters.first { key, _ in key == "username" }
        #expect(repParameter?.value == "$response.body#/username")
        #expect(userRepositoriesLink.requestBody == "$response.body#/username")
    }

    @Test
    func testDynamicMemberLookup() throws {
        let person = Person()
        let age: Int = person.age
        let name: String = person.name
        _ = name
        _ = age
        let addressedPerson = AddressedPerson()
        addressedPerson.printAddress("Gernlindener Weg 23")
    }

    
}
