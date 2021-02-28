//
//  SemifinalInteractor.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 04.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol SemifinalInteractorProtocol {
    func setupInitialData()
}

final class SemifinalInteractor {

    // MARK: - Private Properties

    private let presenter: SemifinalPresenterProtocol


    // MARK: - Init

    init(presenter: SemifinalPresenterProtocol) {
        self.presenter = presenter
    }
}

// MARK: - FinalInteractorProtocol

extension SemifinalInteractor: SemifinalInteractorProtocol {
    func setupInitialData() {
        // TODO: Перенести сюда логику запуска
    }
}

