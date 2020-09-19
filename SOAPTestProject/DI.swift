//
//  DI.swift
//  SOAPTestProject
//
//  Created by Andrew on 19.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Swinject

enum ContainerError: Error {
    case unwrapped
}

enum Module: String {
    case test
}

extension Container {
    static let shared = Container().with {
        $0.register(UINavigationController.self, name: Module.test.rawValue) { _ in
            UINavigationController(
                rootViewController: SOAPTestViewController(
                    with: SOAPTestViewModel(
                        with: SOAPTestService()
                    )
                )
            )
        }
    }
    
    private func localResolve<Service>(_ serviceType: Service.Type) throws -> Service {
        guard let resolver = resolve(serviceType) else { throw ContainerError.unwrapped }
        return resolver
    }
    
    private func localResolve<Service>(_ serviceType: Service.Type, name: String) throws -> Service {
        guard let resolver = resolve(serviceType, name: name) else { throw ContainerError.unwrapped }
        return resolver
    }
    
    private func resolve<Service>(_ serviceType: Service.Type, module: Module) throws -> Service {
        guard let resolver = resolve(serviceType, name: module.rawValue) else { throw ContainerError.unwrapped }
        return resolver
    }
    
    func resolveViewController(module: Module) throws -> UIViewController {
        try resolve(UIViewController.self, module: module)
    }
    
    func resolveNavigationController(module: Module) throws -> UINavigationController {
        try resolve(UINavigationController.self, module: module)
    }
}
