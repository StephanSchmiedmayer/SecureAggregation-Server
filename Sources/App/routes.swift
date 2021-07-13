import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    let normalAggregation = app.grouped("NormalAggregation")
    
//    normalAggregation.get() { req -> String
//
//    }
    let seucreAggregation = app.grouped("SecureAggregation")

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.get("count") { req -> String in
        return "\(Test.shared.count)"
    }
}
