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
        let finalManager = FinalManager(networkClient: networkClient)

        let alertFactory = AlertFactory()
    
        let router = FinalRouter(alertFactory: alertFactory)
        let presenter = FinalPresenter()
        let interactor = FinalInteractor(presenter: presenter,
                                         router: router,
                                         ratingManager: ratingManager,
                                         profileManager: profileManager,
                                         finalManager: finalManager)
        let viewController = FinalViewController(interactor: interactor)

        alertFactory.viewController = viewController
        presenter.viewController = viewController
        router.viewController = viewController
        
        return viewController
    }
}
