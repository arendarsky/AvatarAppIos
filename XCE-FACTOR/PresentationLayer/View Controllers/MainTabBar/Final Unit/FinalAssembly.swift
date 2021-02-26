//
//  FinalAssembly.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// Сборщик экрана финала
final class FinalAssembly {
    static func build() -> UIViewController {
        let networkClient = NetworkClient()
        let ratingManager = RatingManager(networkClient: networkClient)
        let profileManager = ProfileServicesManager(networkClient: networkClient)
        
        let router = FinalRouter()
        let presenter = FinalPresenter()
        let interactor = FinalInteractor(presenter: presenter,
                                         router: router,
                                         ratingManager: ratingManager,
                                         profileManager: profileManager)
        let viewController = FinalViewController(interactor: interactor)

        presenter.viewController = viewController
        router.viewController = viewController
        
        return viewController
    }
}
