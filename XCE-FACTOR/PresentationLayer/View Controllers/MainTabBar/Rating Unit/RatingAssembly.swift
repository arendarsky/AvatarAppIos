//	RatingAssembly.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 06.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// Cборка процесса Рейтинг
final class RatingAssembly {

	/// Создает `ViewController` процесса Рейтинга и настраивает зависимости
	///
	/// - Returns: `ViewController`
	static func build() -> UIViewController {

        let networkClient = NetworkClient()
        let profileManager = ProfileServicesManager(networkClient: networkClient)
        let ratingManager = RatingManager(networkClient: networkClient)

		let presenter = RatingPresenter()
		let router = RatingRouter()
        let interactor = RatingInteractor(presenter: presenter,
                                          router: router,
                                          ratingManager: ratingManager,
                                          profileManager: profileManager)
        let viewController = RatingViewController(interactor: interactor,
                                                  profileManager: profileManager,
                                                  ratingManager: ratingManager)

		presenter.viewController = viewController
		router.viewController = viewController

		return viewController
	}
}
