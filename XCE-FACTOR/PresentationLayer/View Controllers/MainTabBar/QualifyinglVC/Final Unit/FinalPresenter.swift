//
//  FinalPresenter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

protocol FinalPresenterProtocol {
    func present(secondsUntilStart: Int, secondsUntilEnd: Int, finalists: [FinalistModel])

    func present(voiceLimit: Int, voiceLeft: Int)

    func presentStreamingVideo(link: URL)

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
    
    func presentStreamingVideo(link: URL) {
        viewController?.setupStreaming(videoURL: link)
    }
    
    func presentFinalistsNotAvailable() {
        viewController?.showError()
    }
    
    func present(secondsUntilStart: Int, secondsUntilEnd: Int, finalists: [FinalistModel]) {
        var finalistModels: [FinalistTableCellModel] = []
        var timerDate: Date
        var timerText: String

        if secondsUntilStart != 0 {
            timerDate = configureDate(for: secondsUntilStart)
            timerText = "До окончания голосования:"
        } else {
            timerText = "Голосование начнется через:"
            timerDate = configureDate(for: secondsUntilEnd)
        }

        finalists.forEach { finalist in
            let model = FinalistTableCellModel(id: finalist.contestant.id,
                                               image: nil,
                                               name: finalist.contestant.name,
                                               voted: finalist.isVotedByUser)
            finalistModels.append(model)
        }

        viewController?.display(timerText: timerText, timerTime: timerDate, cellsModels: finalistModels)
    }

    func present(voiceLimit: Int, voiceLeft: Int) {
        viewController?.changeVoiceStatus(numberOfVoices: voiceLimit - voiceLeft)
    }

    func cancelVoice(id: Int) {
        viewController?.cancelVoice(id: id)
    }
}

// MARK: - Private Methods

private extension FinalPresenter {
    func configureDate(for timerSeconds: Int) -> Date {
        let currentDate = Date()
        let hours = timerSeconds / 3600
        let hoursRemainder = timerSeconds % 3600
        let minutes = hoursRemainder / 60
        let seconds = hoursRemainder % 60

        var timerTime = currentDate.add(type: .hour, value: hours)
        timerTime = timerTime.add(type: .minute, value: minutes)
        timerTime = timerTime.add(type: .second, value: seconds)

        return timerTime
    }
}
