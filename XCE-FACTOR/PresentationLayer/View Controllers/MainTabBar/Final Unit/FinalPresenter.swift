//
//  FinalPresenter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

protocol FinalPresenterProtocol {
    func present(finalists: [RatingProfile])

    func presentStreamingVideo(link: URL, timer: Date)

    func presentFinalistsNotAvailable()

    func presentProfileImage(image: UIImage, at position: Int)
}

final class FinalPresenter {
    weak var viewController: FinalViewControllerProtocol?
}

// MARK: - FinalPresenterProtocol

extension FinalPresenter: FinalPresenterProtocol {
    func presentProfileImage(image: UIImage, at position: Int) {
        viewController?.setProfileImage(image, at: position)
    }
    
    func presentStreamingVideo(link: URL, timer: Date) {
        viewController?.setupStreaming(videoURL: link, timer: timer)
    }
    
    func presentFinalistsNotAvailable() {
//        viewController.
    }
    
    func present(finalists: [RatingProfile]) {
        var finalistModels: [FinalistTableCellModel] = []

        for (index, finalist) in finalists.enumerated() {
            let model = FinalistTableCellModel(id: index,
                                               image: nil,
                                               name: finalist.name,
                                               voted: true)
            finalistModels.append(model)
        }

        viewController?.display(cellsModels: finalistModels)
    }
}
