//
//  FinalPresenter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol FinalPresenterProtocol {
    func present(finalists: [RatingProfile])
}

final class FinalPresenter {
    weak var viewController: FinalViewControllerProtocol?
}

// MARK: - FinalPresenterProtocol

extension FinalPresenter: FinalPresenterProtocol {
    func present(finalists: [RatingProfile]) {
        var cellsModels: [FinalistTableCellModel] = []

        finalists.forEach { profile in
            let model = FinalistTableCellModel(image: nil, name: profile.name, voted: true)
            cellsModels.append(model)
        }

        viewController?.display(cellsModels: cellsModels)
    }
}
