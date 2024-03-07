//
//  File.swift
//  
//
//  Created by Stephan Schmiedmayer on 07.03.24.
//

import Foundation
import Vapor
import SecureAggregationCore

struct AutomaticSARoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
//        addRoute(to: routes, endpoint: .start, use: automaticSAController.start)
        
        addRoute(to: routes, endpoint: .login, use: automaticSAController.login)
        
        addRoute(to: routes, endpoint: .setup, use: automaticSAController.setup)
        
        addRoute(to: routes, endpoint: .round0ClientMessage, use: automaticSAController.round0ClientMessage)
        addRoute(to: routes, endpoint: .round0ServerMessage, use: automaticSAController.round0ServerResponse)
        
        addRoute(to: routes, endpoint: .round1ClientMessage, use: automaticSAController.round1ClientMessage)
        addRoute(to: routes, endpoint: .round1ServerMessage, use: automaticSAController.round1ServerResponse)
        
        addRoute(to: routes, endpoint: .round2ClientMessage, use: automaticSAController.round2ClientMessage)
        addRoute(to: routes, endpoint: .round2ServerMessage, use: automaticSAController.round2ServerResponse)

        addRoute(to: routes, endpoint: .round4ClientMessage, use: automaticSAController.round4ClientMessage)
        addRoute(to: routes, endpoint: .round4ServerMessage, use: automaticSAController.round4ServerResponse)
        
        routes.on(.GET, "SecureAggregation", "state", use: automaticSAController.getState)
    }
    
    /// Adds the route defined by `endpoint` to `route` with the given `closure`
    private func addRoute<Response>(to route: RoutesBuilder,
                                    endpoint: SABasicAPI,
                                    use closure: @escaping (Request) throws -> Response)
    where Response: ResponseEncodable  {
        route.on(endpoint.info.method.vaporHttpMethod,
                 "\(endpoint.info.commonBaseURL)",
                 "\(endpoint.info.differentiatingRelativeURL)",
                 use: closure)
    }
}
