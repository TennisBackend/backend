import Vapor
import FluentProvider
import HTTP

final class User: Model {
    let storage = Storage()

    // MARK: Properties and database keys

    /// The column names for `id` and `content` in the database
    static let idKey = "id"
    static let firstNameKey = "first_name"
    static let lastNameKey = "last_name"
    static let loginKey = "login"
    static let passwordKey = "password"

    fileprivate var firstName: String
    fileprivate var lastName: String
    fileprivate var login: String
    fileprivate var password: String

    /// Creates a new Post
    init(firstName: String,
         lastName: String,
         login: String,
         password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.login = login
        self.password = password
    }

    // MARK: Fluent Serialization

    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        firstName = try row.get(User.firstNameKey)
        lastName = try row.get(User.lastNameKey)
        login = try row.get(User.loginKey)
        password = try row.get(User.passwordKey)
    }

    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.firstNameKey, firstName)
        try row.set(User.lastNameKey, lastName)
        try row.set(User.loginKey, login)
        try row.set(User.passwordKey, password)

        return row
    }
}

// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.firstNameKey)
            builder.string(User.lastNameKey)
            builder.string(User.loginKey)
            builder.string(User.passwordKey)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            firstName: json.get(User.firstNameKey),
            lastName: json.get(User.lastNameKey),
            login: json.get(User.loginKey),
            password: json.get(User.passwordKey)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.firstNameKey, firstName)
        try json.set(User.lastNameKey, lastName)
        try json.set(User.loginKey, login)
        try json.set(User.passwordKey, password)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

