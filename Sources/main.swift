// The Swift Programming Language
// https://docs.swift.org/swift-book

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
