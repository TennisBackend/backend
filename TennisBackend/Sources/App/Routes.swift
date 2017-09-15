import Vapor

extension Droplet {
    func setupRoutes() throws {
        post("user") { req in
            guard let json = req.json else {
                throw Abort(.badRequest, reason: "no json provided")
            }

            let user: User
            // try to initialize user with json
            do {
                user = try User(json: json)
            }
            catch {
                throw Abort(.badRequest, reason: "incorrect json")
            }
            
            // save user
            try user.save()
            // return user
            return try user.makeJSON()
        }

        get("hello") { req in
            var json = JSON()
            try json.set("yo", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}
