//
//  SemifinalAssembly.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 04.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// Сборщик экрана финала
final class SemifinalAssembly {
    static func build() -> UIViewController {
        let networkClient = NetworkClient()
        let profileManager = ProfileServicesManager(networkClient: networkClient)
        let semifinalManager = SemifinalManager(networkClient: networkClient)
        
        let router = SemifinalRouter()
        let presenter = SemifinalPresenter()
        let interactor = SemifinalInteractor(presenter: presenter)
        let viewController = SemifinalVC(interactor: interactor,
                                         router: router,
                                         semifinalManager: semifinalManager,
                                         profileManager: profileManager)

        presenter.viewController = viewController
        router.viewController = viewController
        
        return viewController
    }
}
