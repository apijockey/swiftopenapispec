import XCTest
import Yams
import SwiftUI
@testable import SwiftOpenAPISpec
final class openapispecreaderTests: XCTestCase {
    func testBasics() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.version, "3.1.0")
        XCTAssertEqual(apiSpec.info.title, "GreetingService")
        XCTAssertEqual(apiSpec.info.version, "1.0.0")
        XCTAssertEqual(apiSpec.info.summary, "Prints a greeting on GET request")
        XCTAssertEqual(apiSpec.info.termsOfService, "Displayss the terms of services")
        XCTAssertEqual(apiSpec.info.contact?.name ?? "", "API Support")
        XCTAssertEqual(apiSpec.info.contact?.url ?? "", "https://www.example.com/support")
        XCTAssertEqual(apiSpec.info.contact?.email ?? "", "support@example.com")
        XCTAssertEqual(apiSpec.info.license?.name ?? "", "Apache 2.0")
        XCTAssertEqual(apiSpec.info.license?.url ?? "", "https://www.apache.org/licenses/LICENSE-2.0.html")
    }
    func testServers() throws {
        
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.servers.count, 3)
        XCTAssertEqual(apiSpec.servers[0].url, "https://example.com/api")
        XCTAssertEqual(apiSpec.servers[0].description, "Example service deployment.")
        XCTAssertEqual(apiSpec.servers[1].url, "http://127.0.0.1:8080/api")
        XCTAssertEqual(apiSpec.servers[1].description, "Localhost deployment.")
        XCTAssertEqual(apiSpec.servers[2].variables.count, 3)
        guard let usernameVariable = apiSpec.servers[2].variables.first(where: { variable in
            variable.key == "username"
        }) else {
            XCTFail("no username variable")
            return
        }
        XCTAssertEqual(usernameVariable.defaultValue, "demo")
        XCTAssertEqual(usernameVariable.description, "this value is assigned by the service provider, in this example `gigantic-server.com`")
        XCTAssertNil(usernameVariable.enumList)
        // Port
        guard let portVariable = apiSpec.servers[2].variables.first(where: { variable in
            variable.key == "port"
        }) else {
            XCTFail("no port variable")
            return
        }
        XCTAssertEqual(portVariable.defaultValue, "8443")
        XCTAssertEqual(portVariable.enumList?.count,2)
        XCTAssertNotNil(portVariable.enumList?.first(where: {$0 == "8443"}))
        XCTAssertNotNil(portVariable.enumList?.first(where: {$0 == "443"}))

    }
    func testPathInfo() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.paths.count, 4)
        let getGreetPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/greet"
        })
        XCTAssertEqual(getGreetPath.operations.count,1)
        let getEmojiPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/emoji"
        })
        let getClipPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/clip"
        })
        XCTAssertEqual(getGreetPath.operations.count, 1)
        XCTAssertEqual(getEmojiPath.operations.count, 1)
        XCTAssertEqual(getClipPath.operations.count, 1)
        let emojiPathOperation = try XCTUnwrap(getEmojiPath.operations.first)
        XCTAssertEqual(emojiPathOperation.responses?.count,1)
    
        
        XCTAssertEqual(emojiPathOperation.key,"get")
        let clipPathOperation = try XCTUnwrap(getClipPath.operations.first)
        XCTAssertEqual(clipPathOperation.key,"get")
        let greetingPathOperation = try XCTUnwrap(getGreetPath.operations.first)
        XCTAssertEqual(clipPathOperation.key,"get")
    }
    func testOperations() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        let getClipPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/clip"
        })
        let clipPathOperation = try XCTUnwrap(getClipPath.operations.first)
        XCTAssertEqual(clipPathOperation.key,"get")
        XCTAssertEqual(clipPathOperation.responses?.count,1)
        XCTAssertEqual(clipPathOperation.operationId,"getClip")
        let response  = try XCTUnwrap(clipPathOperation.responses?.first)
        XCTAssertEqual(response.description,"Returns a cat video! 😽")
        XCTAssertEqual(response.key,"200")
    }
    func testParameters() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        let getGreetPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/greet"
        })
        let getEmojiPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/emoji"
        })
        let getClipPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/clip"
        })
        let clipPathOperation = try XCTUnwrap(getClipPath.operations.first)
        let emojiPathOperation = try XCTUnwrap(getEmojiPath.operations.first)
        let greetPathOperation = try XCTUnwrap(getGreetPath.operations.first)
        XCTAssertEqual(clipPathOperation.parameters?.count,0)
        XCTAssertEqual(emojiPathOperation.parameters?.count,0)
        XCTAssertEqual(greetPathOperation.parameters?.count,1)
        let greetPathParameter = try XCTUnwrap(greetPathOperation.parameters?.first)
        XCTAssertEqual(greetPathParameter.name, "name")
        XCTAssertEqual(greetPathParameter.required, false)
        XCTAssertEqual(greetPathParameter.location, OpenAPIParameter.ParameterLocation.query)
        XCTAssertEqual(greetPathParameter.description, "The name used in the returned greeting.")
        XCTAssertTrue(greetPathParameter.schema?.schemaType is OpenAPIValidatableStringType)
        XCTAssertNil(greetPathParameter.allowEmptyValue)
        XCTAssertNil(greetPathParameter.allowEmptyValue)
    }
    func testResponses() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        let getGreetPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/greet"
        })
        let greetPathOperation = try XCTUnwrap(getGreetPath.operations.first)
        let response = try XCTUnwrap(greetPathOperation.responses?.first)
        XCTAssertEqual(response.key,"200")
        XCTAssertEqual(response.content.count, 1)
        let content = try XCTUnwrap(response.content.first)
        XCTAssertEqual(content.key,"application/json")
        XCTAssertEqual(content.schemaRef?.ref,"#/components/schemas/Greeting")
    }
    func testSchemaComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.components?.schemas.count,4)
        let greetingComponent = try XCTUnwrap(apiSpec.components?.schemas.first { path in
            path.key == "Greeting"
        })
        XCTAssertNotNil(greetingComponent)
        let greetingObject = try XCTUnwrap(greetingComponent.namedComponentType?.schemaType as? OpenAPIValidatableObjectType)
        XCTAssertEqual(greetingObject.properties.count, 1)
        let messageProperty = try XCTUnwrap(greetingObject.properties.first)
        XCTAssertTrue(messageProperty.type is OpenAPIValidatableStringType)
        XCTAssertEqual(greetingObject.required, ["message"])
        let generalErrorComponent = try XCTUnwrap(apiSpec.components?.schemas.first { path in
            path.key == "GeneralError"
        })
        XCTAssertNotNil(generalErrorComponent)
        let errorObject = try XCTUnwrap(greetingComponent.namedComponentType?.schemaType as? OpenAPIValidatableObjectType)
        XCTAssertEqual(errorObject.properties.count, 2)
        let errorMessageCodeProperty =  errorObject.properties.first(where: { prop in
            prop.key == "code"
                        
        })
        XCTAssertTrue(errorMessageCodeProperty?.type is OpenAPIValidatableIntegerType)
        let errorMessageMessageProperty =  errorObject.properties.first(where: { prop in
            prop.key == "message"
                        
        })
        XCTAssertTrue(errorMessageMessageProperty?.type is OpenAPIValidatableStringType)
        XCTAssertEqual(errorObject.required.count, 0)
    }
    func testParameterComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.components?.parameters.count,2)
        let skipParamComponent = try XCTUnwrap(apiSpec.components?.parameters.first { path in
            path.key == "skipParam"
        })
        XCTAssertEqual(skipParamComponent.namedComponentType?.name, "skip")
        XCTAssertEqual(skipParamComponent.namedComponentType?.location, OpenAPIParameter.ParameterLocation.query)
        XCTAssertEqual(skipParamComponent.namedComponentType?.description, "number of items to skip")
        XCTAssertEqual(skipParamComponent.namedComponentType?.required, true)
        XCTAssertTrue(skipParamComponent.namedComponentType?.schema?.schemaType is  OpenAPIValidatableIntegerType)
        XCTAssertEqual(skipParamComponent.namedComponentType?.schema?.format, OpenAPISchema.DataType.int32)
    }
    func testResponsesComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.components?.responses.count,4)
        let notFoundResponseOptional = apiSpec.components?.responses.first(where: { response in
            response.key == "NotFound"
        })
        let notFoundResponse = try XCTUnwrap(notFoundResponseOptional)
        XCTAssertEqual( notFoundResponse.description,"Entity not found.")
        let ImageResponseOptional = apiSpec.components?.responses.first(where: { response in
            response.key == "ImageResponse"
        })
        let ImageResponse = try XCTUnwrap(ImageResponseOptional)
        XCTAssertEqual( ImageResponse.description,"An image.")
        let IllegalInputOptional = apiSpec.components?.responses.first(where: { response in
            response.key == "IllegalInput"
        })
        let IllegalInput = try XCTUnwrap(IllegalInputOptional)
        XCTAssertEqual( IllegalInput.description,"Illegal input for operation.")
        let GeneralErrorOptional = apiSpec.components?.responses.first(where: { response in
            response.key == "GeneralError"
        })
        let GeneralError = try XCTUnwrap(GeneralErrorOptional)
        XCTAssertEqual( GeneralError.description,"General Error")
        XCTAssertEqual( GeneralError.content.count,1)
        let jsonContentOpt = GeneralError.content.first { content in
            content.key == "application/json"
        }
        XCTAssertNotNil(jsonContentOpt)
        let jsonContent = try XCTUnwrap(jsonContentOpt)
        XCTAssertEqual( jsonContent.schemaRef?.ref,"#/components/schemas/GeneralError")
        
    }
    func testRequestBody() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.paths.count, 4)
        let getPetsPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/pets"
        })
        let postOperation = try XCTUnwrap(getPetsPath.operations.first { operation in
            operation.key == "post"
        })
        XCTAssertEqual(postOperation.requestBody?.description,"Optional description in *Markdown*")
        XCTAssertEqual(postOperation.requestBody?.required,true)
        XCTAssertEqual(postOperation.requestBody?.contents.count,4)
        
        
        
    }
    func testOneOfSchema() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.paths.count, 4)
        let getPetsPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/pets"
        })
        XCTAssertEqual(getPetsPath.operations.count, 3)
        let patchOperation = try XCTUnwrap(getPetsPath.operations.first { operation in
            operation.key == "patch"
        })
       
        XCTAssertEqual(patchOperation.requestBody?.required,false)
        let jsonContentOpt = patchOperation.requestBody?.contents.first(where: { content in
            content.key == "application/json"
        })
        XCTAssertNotNil(jsonContentOpt)
        let jsonContent = try XCTUnwrap(jsonContentOpt)
        XCTAssertEqual(jsonContent.oneOfSchemas?.schemaRefs.count, 2)
        XCTAssertEqual(jsonContent.oneOfSchemas?.schemas.count, 0)
    }
    func testOperationSecurityScheme() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.paths.count, 4)
        let getGreetPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/greet"
        })
        let getOperation = try XCTUnwrap(getGreetPath.operations.first { operation in
            operation.key == "get"
        })
        XCTAssertEqual(getOperation.securityObjects.count,2)
        let petStoreAuth = try XCTUnwrap(getOperation.securityObjects.first { $0.key == "petstore_auth" })
        XCTAssertTrue(petStoreAuth.scopes.contains("write:pets"))
        XCTAssertTrue(petStoreAuth.scopes.contains("read:pets"))
        let clipStoreAuth = try XCTUnwrap(getOperation.securityObjects.first { $0.key == "clip_auth" })
        XCTAssertTrue(clipStoreAuth.scopes.contains("write:clips"))
        XCTAssertTrue(clipStoreAuth.scopes.contains("read:clips"))
    }
    func testSecurityComponents() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.components?.securitySchemas.count,5)
        let httpKeySecurityScheme = try XCTUnwrap(apiSpec.components?.securitySchemas.first{ $0.key == "http_Key"})
        XCTAssertEqual(httpKeySecurityScheme.securityType,.http)
        XCTAssertEqual(httpKeySecurityScheme.httpScheme , "basic")
        
        let apiKeySecurityScheme = try XCTUnwrap(apiSpec.components?.securitySchemas.first{ $0.key == "api_key"})
        XCTAssertEqual(apiKeySecurityScheme.securityType,.apiKey)
        XCTAssertEqual(apiKeySecurityScheme.apiKeyName , "api_key")
        XCTAssertEqual(apiKeySecurityScheme.ApiKeyIn , .header)
        
        let bearerKeySecurityScheme = try XCTUnwrap(apiSpec.components?.securitySchemas.first{ $0.key == "bearer_key"})
        XCTAssertEqual(bearerKeySecurityScheme.securityType,.http)
        XCTAssertEqual(bearerKeySecurityScheme.httpScheme, "bearer")
        XCTAssertEqual(bearerKeySecurityScheme.httpBearerFormat, "JWT")
        
        let petStoreOAuth2KeySecurityScheme = try XCTUnwrap(apiSpec.components?.securitySchemas.first{ $0.key == "petstore_auth"})
        XCTAssertEqual(petStoreOAuth2KeySecurityScheme.securityType,.oauth2)
        XCTAssertNotNil(petStoreOAuth2KeySecurityScheme.flows?.implicit)
        let flowImplicit = try XCTUnwrap(petStoreOAuth2KeySecurityScheme.flows?.implicit)
        XCTAssertEqual(flowImplicit.authorizationUrl, "https://example.org/api/oauth/dialog")
        XCTAssertEqual(flowImplicit.scopes?.count,2)
        XCTAssertTrue(flowImplicit.scopes?.contains(where: {key,value in key == "write:pets"}) ?? false)
        XCTAssertTrue(flowImplicit.scopes?.contains(where: {key,value in
                key == "read:pets"}) ?? false)
        
        let clipStoreOAuth2KeySecurityScheme = try XCTUnwrap(apiSpec.components?.securitySchemas.first{ $0.key == "clip_auth"})
        XCTAssertEqual(clipStoreOAuth2KeySecurityScheme.securityType,.oauth2)
        XCTAssertNotNil(clipStoreOAuth2KeySecurityScheme.flows?.implicit)
        let clipflowImplicit = try XCTUnwrap(clipStoreOAuth2KeySecurityScheme.flows?.implicit)
        XCTAssertEqual(clipflowImplicit.authorizationUrl, "https://example.com/api/oauth/dialog")
        XCTAssertNotNil(clipStoreOAuth2KeySecurityScheme.flows?.authorizationCode)
        let clipflowAuthorizationCode = try XCTUnwrap(clipStoreOAuth2KeySecurityScheme.flows?.authorizationCode)
        XCTAssertEqual(clipflowAuthorizationCode.authorizationUrl, "https://example.com/api/oauth/dialog")
        XCTAssertEqual(clipflowAuthorizationCode.tokenUrl, "https://example.com/api/oauth/token")
        XCTAssertEqual(clipflowAuthorizationCode.tokenUrl, "https://example.com/api/oauth/token")
        XCTAssertEqual(clipflowAuthorizationCode.scopes?.count,2)
        XCTAssertTrue(clipflowAuthorizationCode.scopes?.contains(where: {key,value in key == "write:clips"}) ?? false)
        XCTAssertTrue(clipflowAuthorizationCode.scopes?.contains(where: {key,value in
                key == "read:clips"}) ?? false)
    }
    func testExamples()throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.paths.count, 4)
        let getPetsPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/pets"
        })
        XCTAssertEqual(getPetsPath.operations.count, 3)
        let postOperation = try XCTUnwrap(getPetsPath.operations.first { operation in
            operation.key == "post"
        })
        let mediatype = try XCTUnwrap(postOperation.requestBody?.contents.first(where: { mediatype in
            mediatype.key == "text/plain"
        }))
        XCTAssertEqual(mediatype.examples.count,3)
        let userExample = mediatype.examples.first { $0.key == "user"}
        XCTAssertEqual(userExample?.summary,"User example in Plain text")
        XCTAssertEqual(userExample?.externalValue, "https://foo.bar/examples/user-example.txt")
        let fooExample = mediatype.examples.first { $0.key == "foo"}
        XCTAssertEqual(fooExample?.summary,"A foo example")
        XCTAssertNotNil(fooExample?.value)
        let barExample = mediatype.examples.first { $0.key == "bar"}
        XCTAssertEqual(barExample?.summary,"A bar example")
        XCTAssertNotNil(barExample?.value)
        
    }
    func testExamplesRef() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        XCTAssertEqual(apiSpec.paths.count, 4)
        let getPetsPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/pets"
        })
        XCTAssertEqual(getPetsPath.operations.count, 3)
        let patchOperation = try XCTUnwrap(getPetsPath.operations.first { operation in
            operation.key == "patch"
        })
        let mediatype = try XCTUnwrap(         patchOperation.requestBody?.contents.first(where: { mediatype in
            mediatype.key == "application/json"
        }))
        XCTAssertEqual(mediatype.examples.count,1)
        let refExample = try XCTUnwrap(mediatype.examples.first { example in
            example.key == "confirmation-success"
        })
        XCTAssertEqual(refExample.ref,"#/components/examples/confirmation-success")
    }
    func testLinks() throws {
        guard let settingsURL = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else {
            XCTFail("no openapi")
            return
        }
        let data = try Data(contentsOf: settingsURL)
        guard let string = String(data: data, encoding: .utf8) else  {
            XCTFail("no valid yaml")
            return
        }
        let apiSpec = try OpenAPISpec.read(text: string)
        let getPetsPath = try XCTUnwrap(apiSpec.paths.first { path in
            path.key == "/pets"
        })
        let patchOperation = try XCTUnwrap(getPetsPath.operations.first { operation in
            operation.key == "patch"
        })
        let links = try XCTUnwrap(patchOperation.responses?.first(where: { $0.key == "200" })?.links)
        XCTAssertEqual(links.count, 2)
        let addressLink = try XCTUnwrap(links.first {$0.key == "address" })
        XCTAssertEqual(addressLink.operationId,"getUserAddress")
        XCTAssertEqual(addressLink.parameters.count,1)
        let parameter = addressLink.parameters.first { key,value in
            key == "userId"
        }
        XCTAssertEqual(parameter?.value, "$request.path.id")
        let userRepositoriesLink = try XCTUnwrap(links.first {$0.key == "UserRepositories" })
        XCTAssertEqual(userRepositoriesLink.operationRef,"#/paths/~12.0~1repositories~1{username}/get")
        XCTAssertEqual(userRepositoriesLink.parameters.count,1)
        let repParameter = userRepositoriesLink.parameters.first { key,value in
            key == "username"
        }
        XCTAssertEqual(repParameter?.value, "$response.body#/username")
        XCTAssertEqual(userRepositoriesLink.requestBody,"$response.body#/username")
    }
    func testDynamicMemberLookup() throws {
        let person = Person()
        let age : Int = person.age
        let name : String = person.name
        print(name)
        print(age)
        let addressedPerson = AddressedPerson()
        addressedPerson.printAddress("Gernlindener Weg 23")
    }
    func testSubscript() throws {
        let aset : Set<Edge> = [Edge.top, Edge.bottom]
        XCTAssertEqual(aset[contains: .top],true)
        
        let json = JSON.intValue(5)
        print(json.stringValue)
        let jsonArray = JSON.arrayValue([JSON.intValue(2),JSON.intValue(5),JSON.intValue(8),JSON.intValue(1)])
        XCTAssertNil(jsonArray[5])
        XCTAssertEqual(jsonArray[2]?.stringValue,"8")
    }
}
