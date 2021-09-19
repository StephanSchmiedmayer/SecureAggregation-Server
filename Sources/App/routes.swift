import Fluent
import Vapor

func routes(_ app: Application) throws {
    let secureAggregationController = BasicSecureAggregationRoutes()
    try app.register(collection: secureAggregationController)
}
