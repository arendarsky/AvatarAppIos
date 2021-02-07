//	RatingInteractor.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 06.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Протокол интерактора экрана Рейтинга
protocol RatingInteractorProtocol {
    /// Загрузка начального состояния экрана
    func setupInitialData()
}

/// Интерактор экрана Рейтинга
final class RatingInteractor {

    // MARK: - Private Properties

	private let presenter: RatingPresenterProtocol
    private let ratingManager: RatingManagerProtocol

    // MARK: - Init

	/// Инициализатор
    ///
	/// - Parameters:
	///   - presenter: Презентер экрана Рейтинга
	init(presenter: RatingPresenterProtocol, ratingManager: RatingManagerProtocol) {
		self.presenter = presenter
        self.ratingManager = ratingManager
	}
}

// MARK: - RatingInteractorProtocol

extension RatingInteractor: RatingInteractorProtocol {
    func setupInitialData() {
        // TODO: Перенести из VC:
        // updateRatingItems()
        // updateSemifinalists()
    }
}

// MARK: - Private Methods

private extension RatingInteractor {
    func updateFinalists() {
    }
}
