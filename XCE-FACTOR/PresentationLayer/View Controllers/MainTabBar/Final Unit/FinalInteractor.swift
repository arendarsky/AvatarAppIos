//
//  FinalInteractor.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol FinalInteractorProtocol {
    func setupInitialData()
}

final class FinalInteractor {

    // MARK: - Private Properties

    private let presenter: FinalPresenterProtocol
    private let router: FinalRouterProtocol
    private let ratingManager: RatingManagerProtocol

    // MARK: - Init

    init(presenter: FinalPresenterProtocol,
         router: FinalRouterProtocol,
         ratingManager: RatingManagerProtocol) {
        self.presenter = presenter
        self.router = router
        self.ratingManager = ratingManager
    }
}

// MARK: - FinalInteractorProtocol

extension FinalInteractor: FinalInteractorProtocol {
    func setupInitialData() {
        // TODO: Временная реализация для тестирования отображения
        // Заменить на финалистов
        presenter.present(finalists: [])
//        ratingManager.fetchSemifinalists { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let finalists):
//                self.presenter.present(finalists: finalists)
//                self.loadProfileImages(for: finalists)
//            case .failure: break
//                // TODO: handle Error
//            }
//        }
    }
}

// MARK: - Private Methods

private extension FinalInteractor {
    func loadProfileImages(for finalists: [RatingProfile]) {
        // TODO: Подгружаем иконки
    }
}
