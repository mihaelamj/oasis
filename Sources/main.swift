// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Vapor
import OpenAPIRuntime
import OpenAPIVapor


// Define a type that conforms to the generated protocol.
struct GreetingServiceAPIImpl: APIProtocol {
    func getGreeting(
        _ input: Operations.getGreeting.Input
    ) async throws -> Operations.getGreeting.Output {
        let name = input.query.name ?? "Stranger"
        let greeting = Components.Schemas.Greeting(message: "Hello, \(name)!")
        return .ok(.init(body: .json(greeting)))
    }


    func getEmoji(
        _ input: Operations.getEmoji.Input
    ) async throws -> Operations.getEmoji.Output {
        let emojis = "👋👍👏🙏🤙🤘"
        let emoji = String(emojis.randomElement()!)
        return .ok(.init(body: .plainText(.init(emoji))))
    }
}


// Create Vapor application.
let app = Vapor.Application()

// Create a VaporTransport using that application.
let transport = VaporTransport(routesBuilder: app)

// Create an instance of handler type that conforms the generated protocol
// defininig the service API.
let handler = GreetingServiceAPIImpl()


// Call the generated function on the implementation to add its request
// handlers to the app.
try handler.registerHandlers(on: transport, serverURL: Servers.server1())


// Start the app as you would normally.
try await app.execute()
