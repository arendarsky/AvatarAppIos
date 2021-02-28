//
//  FinalInteractor.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import Foundation
import UIKit.UIImage

/// Протокол интерактора экрана Финала
protocol FinalInteractorProtocol {
    /// Загрузка начального состояния экрана
    func setupInitialData()
    
    /// Обновить данные
    func refreshData()
    
    /// Перейти в профиль финалиста
    /// - Parameter id: Идентификатор участника финала
    func processTransitionToProfile(in id: Int)
    
    /// Отправить голос на бэк
    /// - Parameter id: Идентификатор участника финала
    func sendVote(for id: Int)
}

final class FinalInteractor {

    // MARK: - Private Properties

    private let presenter: FinalPresenterProtocol
    private let router: FinalRouterProtocol

    private let ratingManager: RatingManagerProtocol
    private let profileManager: ProfileServicesManagerProtocol
    private let finalManager: FinalManagerProtocol

    private var finalists: [FinalistModel]
    private var finalistProfileImages: [UIImage?]
    
    /// Прихраниваем ID, в случае ошибки отправки голоса на бэк
    private var lastSendedId: Int
    private var limitOfVoices: Int
    private var voicesLeft: Int

    // MARK: - Init

    init(presenter: FinalPresenterProtocol,
         router: FinalRouterProtocol,
         ratingManager: RatingManagerProtocol,
         profileManager: ProfileServicesManagerProtocol,
         finalManager: FinalManagerProtocol) {
        lastSendedId = 0
        limitOfVoices = 0
        voicesLeft = 0

        finalists = []
        finalistProfileImages = []

        self.presenter = presenter
        self.router = router
        self.ratingManager = ratingManager
        self.profileManager = profileManager
        self.finalManager = finalManager
    }
}

// MARK: - FinalInteractorProtocol

extension FinalInteractor: FinalInteractorProtocol {
    func processTransitionToProfile(in id: Int) {
        guard let index = finalists.firstIndex(where: { $0.contestant.id == id }) else { return }
    
        let finalist = finalists[index].contestant.translatedToUserProfile()
        let image = finalistProfileImages[index]
        router.routeToProfile(for: finalist, profileImage: image)
    }
    
    func setupInitialData() {
        fetchFinalModel()
    }

    func refreshData() {
        fetchFinalModel()
    }

    func sendVote(for id: Int) {
        guard let index = finalists.firstIndex(where: { $0.contestant.id == id }) else { return }

        let finalistVoteID = finalists[index].id
        lastSendedId = finalistVoteID
        finalManager.addVote(for: finalistVoteID) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let isAdd):
                self.voicesLeft = isAdd ? self.voicesLeft + 1 : self.voicesLeft - 1
                self.presenter.present(voiceLimit: self.limitOfVoices, voiceLeft: self.voicesLeft)
                print("Приехал любимый зять, идем пить пивооооооо!")
            case .failure:
                print("Ковальский у нас проблемы!")
                self.router.showError()
                self.presenter.cancelVoice(id: self.lastSendedId)
            }
        }
    }
}

// MARK: - Private Methods

private extension FinalInteractor {

    func fetchFinalModel() {
        finalManager.fetchFinalInfo { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let finalModel):
                if let url = URL(string: finalModel.videoUrl ?? "") {
                    self.presenter.presentStreamingVideo(link: url, timerSeconds: 10)
                }

                self.limitOfVoices = finalModel.winnersNumber
                self.voicesLeft = finalModel.finalists.filter { $0.isVotedByUser }.count

                self.finalists = finalModel.finalists
                self.finalistProfileImages = Array(repeating: nil, count: self.finalists.count)

                self.presenter.present(finalists: self.finalists)
                self.presenter.present(voiceLimit: self.limitOfVoices, voiceLeft: self.voicesLeft)
                self.loadFinalistsProfileImages(for: self.finalists.map { $0.contestant })
            case .failure:
                self.presenter.presentFinalistsNotAvailable()
            }
        }
    }

    func loadFinalistsProfileImages(for finalists: [RatingProfile]) {
        for (index, user) in finalists.enumerated() {
            guard let imageName = user.profilePhoto else { return }
            
            profileManager.getImage(for: imageName) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let image):
                    self.presenter.presentProfileImage(image: image, at: index)
                case .failure: break
                }
            }
        }
    }
}
