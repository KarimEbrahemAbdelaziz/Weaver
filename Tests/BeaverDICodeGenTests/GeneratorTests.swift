//
//  GeneratorTests.swift
//  BeaverDICodeGenTests
//
//  Created by Théophane Rupin on 3/4/18.
//

import Foundation
import XCTest
import SourceKittenFramework
import PathKit

@testable import BeaverDICodeGen

final class GeneratorTests: XCTestCase {
    
    let templatePath = Path(#file).parent() + Path("../../Resources/dependency_resolver.stencil")
    
    func test_generator_should_generate_a_valid_swift_code() {
        
        do {
            let file = File(contents: """
final class MyService {
  let dependencies: DependencyResolver

  // beaverdi: api = API <- APIProtocol
  // beaverdi: api.scope = .graph

  // beaverdi: router = Router <- RouterProtocol
  // beaverdi: router.scope = .container

  // beaverdi: session = Session

  final class MyEmbeddedService {

    // beaverdi: session = Session? <- SessionProtocol?
    // beaverdi: session.scope = .container

    // beaverdi: api <- APIProtocol
  }

  init(_ dependencies: DependencyResolver) {
    self.dependencies = dependencies
  }
}

class AnotherService {
    // This class is ignored
}
""")
            
            let lexer = Lexer(file)
            let tokens = try lexer.tokenize()
            let parser = Parser(tokens, fileName: "test.swift")
            let syntaxTree = try parser.parse()
            
            let generator = try Generator(template: templatePath)
            let string = try generator.generate(from: syntaxTree)
            
            XCTAssertEqual(string, """
/// This file is generated by BeaverDI
/// DO NOT EDIT!


// MARK: - MyService

final class MyServiceDependencyResolver: DependencyResolver {
  
  override func registerDependencies(in store: DependencyStore) {
    
    store.register(APIProtocol.self, scope: .graph, builder: { dependencies in
      return API.makeAPI(injecting: dependencies)
    })
    
    store.register(RouterProtocol.self, scope: .container, builder: { dependencies in
      return Router.makeRouter(injecting: dependencies)
    })
    
    store.register(Session.self, scope: .graph, builder: { dependencies in
      return Session.makeSession(injecting: dependencies)
    })
    
  }
}

// MARK: - Getters

extension MyServiceDependencyResolver {
  
  var api: APIProtocol {
    return dependencies.resolve(APIProtocol.self)
  }
  
  var router: RouterProtocol {
    return dependencies.resolve(RouterProtocol.self)
  }
  
  var session: Session {
    return dependencies.resolve(Session.self)
  }
  
}

// MARK: - Builder

extension MyService {

  static func makeMyService(injecting parentDependencies: DependencyResolver) -> MyService {
    let dependencies = MyServiceDependencyResolver(parentDependencies)
    return MyService(injecting: dependencies)
  }
}

// MARK: - MyEmbeddedService

final class MyEmbeddedServiceDependencyResolver: DependencyResolver {
  
  override func registerDependencies(in store: DependencyStore) {
    
    store.register(SessionProtocol?.self, scope: .container, builder: { dependencies in
      return Session.makeSession(injecting: dependencies)
    })
    
  }
}

// MARK: - Getters

extension MyEmbeddedServiceDependencyResolver {
  
  var session: SessionProtocol? {
    return dependencies.resolve(SessionProtocol?.self)
  }
  
  var api: APIProtocol {
    return dependencies.resolve(APIProtocol.self)
  }
  
}

// MARK: - Builder

extension MyService.MyEmbeddedService {

  static func makeMyEmbeddedService(injecting parentDependencies: DependencyResolver) -> MyEmbeddedService {
    let dependencies = MyEmbeddedServiceDependencyResolver(parentDependencies)
    return MyEmbeddedService(injecting: dependencies)
  }
}

""")
            
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
