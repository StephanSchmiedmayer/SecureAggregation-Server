//
//  File.swift
//  
//
//  Created by stephan on 15.08.21.
//

import Vapor
import SecureAggregationCore

struct BasicSecureAggregationRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
//        let secureAggregationRoute = routes.grouped("SecureAggregation")
        
        addRoute(to: routes, endpoint: .start, use: basicSecureAggregation.start)
        
        addRoute(to: routes, endpoint: .login, use: basicSecureAggregation.login)
        addRoute(to: routes, endpoint: .finishLogin, use: basicSecureAggregation.finishLogin)
        
        addRoute(to: routes, endpoint: .setup, use: basicSecureAggregation.setup)
        addRoute(to: routes, endpoint: .finishSetup, use: basicSecureAggregation.finishSetup)
        
        addRoute(to: routes, endpoint: .round0ClientMessage, use: basicSecureAggregation.round0ClientMessage)
        addRoute(to: routes, endpoint: .finishRound0Collection, use: basicSecureAggregation.finishRound0Collection)
        addRoute(to: routes, endpoint: .round0ServerMessage, use: basicSecureAggregation.round0ServerResponse)
        
        addRoute(to: routes, endpoint: .advanceToRound1, use: basicSecureAggregation.advanceToRound1)
        addRoute(to: routes, endpoint: .round1ClientMessage, use: basicSecureAggregation.round1ClientMessage)
        addRoute(to: routes, endpoint: .finishRound1Collection, use: basicSecureAggregation.finishRound1Collection)
        addRoute(to: routes, endpoint: .round1ServerMessage, use: basicSecureAggregation.round1ServerResponse)
        
        addRoute(to: routes, endpoint: .advanceToRound2, use: basicSecureAggregation.advanceToRound2)
        addRoute(to: routes, endpoint: .round2ClientMessage, use: basicSecureAggregation.round2ClientMessage)
        addRoute(to: routes, endpoint: .finishRound2Collection, use: basicSecureAggregation.finishRound2Collection)
        addRoute(to: routes, endpoint: .round2ServerMessage, use: basicSecureAggregation.round2ServerResponse)

        addRoute(to: routes, endpoint: .advanceToRound4, use: basicSecureAggregation.advanceToRound4)
        addRoute(to: routes, endpoint: .round4ClientMessage, use: basicSecureAggregation.round4ClientMessage)
        addRoute(to: routes, endpoint: .finishRound4Collection, use: basicSecureAggregation.finishRound4Collection)
        addRoute(to: routes, endpoint: .round4ServerMessage, use: basicSecureAggregation.round4ServerResponse)
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

extension SAHTTPMethod {
    var vaporHttpMethod: HTTPMethod {
        switch self {
        case .get: return .GET
        case .post: return .POST
        }
    }
}
