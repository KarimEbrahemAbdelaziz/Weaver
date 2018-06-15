//
//  ResolverSpies.swift
//  SampleTests
//
//  Created by Théophane Rupin on 4/9/18.
//  Copyright © 2018 Scribd. All rights reserved.
//

import Foundation

@testable import API

final class MovieAPIDependencyResolverSpy: MovieAPIDependencyResolver {
    
    init() {
        URLProtocolSpy.clearSpies()
    }
    
    deinit {
        URLProtocolSpy.clearSpies()
    }
    
    // MARK: - Implementation
    
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolSpy.self]
        return URLSession(configuration: config)
    }()
}

final class MovieManagerDependencyResolverSpy: MovieManagerDependencyResolver {
    
    // MARK: - Spies

    var movieAPISpy = APISpy()
    
    // MARK: - Implementation
    
    var movieAPI: APIProtocol {
        return movieAPISpy
    }
    
    let logger = Logger()
}

final class ImageManagerDependencyResolverSpy: ImageManagerDependencyResolver {
    
    init() {
        URLProtocolSpy.clearSpies()
    }

    deinit {
        URLProtocolSpy.clearSpies()
    }
    
    // MARK: - Spies
    
    var movieAPISpy = APISpy()

    // MARK: - Implementation
    
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolSpy.self]
        return URLSession(configuration: config)
    }()
    
    var movieAPI: APIProtocol {
        return movieAPISpy
    }
    
    let logger = Logger()
}
