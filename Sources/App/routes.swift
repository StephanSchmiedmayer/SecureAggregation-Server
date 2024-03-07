import Fluent
import Vapor

func routes(_ app: Application) throws {
//    let secureAggregationController = BasicSecureAggregationRoutes()
    let secureAggregationController = AutomaticSARoutes()
    
    try app.register(collection: secureAggregationController)
}
