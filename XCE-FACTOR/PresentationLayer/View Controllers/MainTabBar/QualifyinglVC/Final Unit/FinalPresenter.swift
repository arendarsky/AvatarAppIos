//
//  FinalPresenter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

protocol FinalPresenterProtocol {
    func present(finalists: [FinalistModel])

    func present(voiceLimit: Int, voiceLeft: Int)

    func presentStreamingVideo(link: URL, timerSeconds: Int)

    func presentFinalistsNotAvailable()

    func presentProfileImage(image: UIImage, at position: Int)

    func cancelVoice(id: Int)
}

final class FinalPresenter {
    weak var viewController: FinalViewControllerProtocol?
}

// MARK: - FinalPresenterProtocol

extension FinalPresenter: FinalPresenterProtocol {
    func presentProfileImage(image: UIImage, at position: Int) {
        viewController?.setProfileImage(image, at: position)
    }
    
    func presentStreamingVideo(link: URL, timerSeconds: Int) {
        let currentDate = Date()
        let hours = timerSeconds / 3600
        let hoursRemainder = timerSeconds % 3600
        let minutes = hoursRemainder / 60
        let seconds = hoursRemainder % 60

        var timerTime = currentDate.add(type: .hour, value: hours)
        timerTime = timerTime.add(type: .minute, value: minutes)
        timerTime = timerTime.add(type: .second, value: seconds)

        viewController?.setupStreaming(videoURL: link, timer: timerTime)
    }
    
    func presentFinalistsNotAvailable() {
//        viewController.
    }
    
    func present(finalists: [FinalistModel]) {
        var finalistModels: [FinalistTableCellModel] = []

        finalists.forEach { finalist in
            let model = FinalistTableCellModel(id: finalist.contestant.id,
                                               image: nil,
                                               name: finalist.contestant.name,
                                               voted: finalist.isVotedByUser)
            finalistModels.append(model)
        }

        viewController?.display(cellsModels: finalistModels)
    }

    func present(voiceLimit: Int, voiceLeft: Int) {
        viewController?.changeVoiceStatus(numberOfVoices: voiceLimit - voiceLeft)
    }

    func cancelVoice(id: Int) {
        viewController?.cancelVoice(id: id)
    }
}
