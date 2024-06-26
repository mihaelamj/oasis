# oasis

## OASIS: OpenAPI SWIFT Internal Server

### Initialize the package in the dir

```bash
swift package init --name oasis --type executable
```

### Usage 

- See the package code
- Run the server and test with curl.

```bash
Server starting on http://127.0.0.1:8080
```
### Example Responses

```bash
% curl 'http://localhost:8080/api/greet?name=Jane'
{
  "message" : "Hello, Jane!"
}
```

### Example Requests

#### Emojis

```bash
curl http://127.0.0.1:8080/api/emoji

curl http://127.0.0.1:8080/api/emojis
```

```bash
curl http://localhost:8080/api/emoji
curl http://127.0.0.1:8080/api/emoji
"👋"
```

#### Names

```bash
curl http://127.0.0.1:8080/api/greet\?name\=Mihaela

curl http://127.0.0.1:8080/api/greetings\?name\=Mihaela
```

## Generating Server code from OpenAPI specs

### Intro

To sidestep the typical hold-ups in iOS frontend development waiting on backend progress, I tapped into the Swift OpenAPI Generator. 
This slick tool fits like a glove with my iOS and macOS development skills, allowing me to quickly spin up a mock backend that's both type-safe and seamlessly integrated.

### Apple's Swift OpenAPI Generator

The Swift OpenAPI Generator is a Swift package plugin developed by Apple that allows users to generate client and server code from OpenAPI documents automatically. 
This tool is particularly useful for creating Swift code that can send and receive HTTP requests based on the OpenAPI specification (versions 3.0 and 3.1). 
It supports various content types and can generate code for both client-side and server-side applications, ensuring type safety and minimal code repetition. 
The code generation happens at build time, which helps keep the generated code in sync with the OpenAPI document and reduces manual coding errors.

### Implementation

Imagine you have some OpenAPI specs in yaml format and want to quickly set up a mock backend. 
Here are the steps to accomplish that using Swift and Vapor:

1. Creating Configuration files
2. Set up the Swift package
3. Expose (implement) the code that has been generated by the **generator** by conforming to the `APIProtocol`
4. Integrate with your chosen server transport (Vapor, AWS Lambda)

#### 1. Creating Configuration files

First, create two key configuration files:

- `openapi-generator-config.yaml`: This file specifies settings for the OpenAPI Generator such as package names, model packages, API versions, and more. This helps tailor the code generation to fit your project requirements.

Example"
```
generate:
  - types
  - server
accessModifier: internal
```

- `openapi.yaml`: This is your OpenAPI specification file in YAML format. Place this file within your project directory so that the OpenAPI Generator can locate and use it to generate server and client code.


#### 2. Setting up the Swift package (Vapor server tansport)

Configure your Swift package to include dependencies necessary for handling OpenAPI and integrating with the Vapor web framework. Define your Package.swift as follows:

```swift
let package = Package(
    name: "oasis",
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor", from: "4.89.0"),
    ],
    targets: [
        .executableTarget(
            name: "oasis",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        )
    ]
)

```


#### 3. Implementing Server Code

Implement the server logic by defining a type, such as OASISServiceAPIImpl, that conforms to the APIProtocol. This protocol will be automatically generated from your OpenAPI specs and outlines the necessary functions that correspond to the API endpoints you defined:

```swift
import Foundation
import Vapor
import OpenAPIRuntime
import OpenAPIVapor


// Define a type that conforms to the generated protocol.
struct OASISServiceAPIImpl: APIProtocol {
    
    func getGreeting(
        _ input: Operations.getGreeting.Input
    ) async throws -> Operations.getGreeting.Output {
        let name = input.query.name ?? "Stranger"
        let greeting = Components.Schemas.Greeting(message: "Hello, \(name)!")
        return .ok(.init(body: .json(greeting)))
    }
    
    func getGreetings(_ input: Operations.getGreetings.Input
    ) async throws -> Operations.getGreetings.Output {
        
        let name = input.query.name ?? "Stranger"
        
        // Define an array to hold multiple greetings
         var greetings: [Components.Schemas.Greeting] = []
         
         // Generate multiple greetings
        let num = Int.random(in: 2...5)
         for i in 1...num { // For example, let's add 3 greetings
             let greetingMessage = "Hello, \(name)! Greeting \(i)"
             let greeting = Components.Schemas.Greeting(message: greetingMessage)
             greetings.append(greeting)
         }
        
        // Return the array of greetings
        return .ok(.init(body: .json(greetings)))
    }


    func getEmoji(
        _ input: Operations.getEmoji.Input
    ) async throws -> Operations.getEmoji.Output {
        let emojis = "👋👍👏🙏🤙🤘"
        let emoji = String(emojis.randomElement()!)
        return .ok(.init(body: .plainText(.init(emoji))))
    }
    
    func getEmojis(
        _ input: Operations.getEmojis.Input
    ) async throws -> Operations.getEmojis.Output {
        let emojis = "👋👍👏🙏🤙🤘" // Emojis to choose from
        
        // Define an array to hold multiple emojis
        var emojisArray: [String] = []
        
        let num = Int.random(in: 2...5)
        
        // Generate multiple emojis
        for _ in 1...num { // For example, let's add 5 emojis
            let randomEmoji = String(emojis.randomElement()!) // Select a random emoji
            emojisArray.append(randomEmoji)
        }
        
        // Return the array of emojis
        return .ok(.init(body: .json(emojisArray)))
    }
}
```

#### 4. Integrating with Vapor

Finally, set up your Vapor application to integrate with the generated OpenAPI logic. Create a VaporTransport to handle routing, register your API implementation to manage requests, and start the application:


```swift
// Create Vapor application.
let app = Vapor.Application()

// Create a VaporTransport using that application.
let transport = VaporTransport(routesBuilder: app)

// Create an instance of handler type that conforms the generated protocol
// defininig the service API.
let handler = OASISServiceAPIImpl()


// Call the generated function on the implementation to add its request
// handlers to the app.
try handler.registerHandlers(on: transport, serverURL: Servers.server1())


// Start the app as you would normally.
try await app.execute()
```


The End.
