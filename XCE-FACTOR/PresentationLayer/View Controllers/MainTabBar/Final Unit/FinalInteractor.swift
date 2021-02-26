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
    
    /// Перейти в профиль финалиста
    /// - Parameter position: Позиция по вертикали с верху
    func processTransitionToProfile(in position: Int)
    
    /// Отправить голос на бэк
    func sendVote()
}

final class FinalInteractor {

    // MARK: - Private Properties

    private let presenter: FinalPresenterProtocol
    private let router: FinalRouterProtocol
    private let ratingManager: RatingManagerProtocol
    private let profileManager: ProfileServicesManagerProtocol

    private var finalists: [RatingProfile]
    private var finalistProfileImages: [UIImage?]

    // MARK: - Init

    init(presenter: FinalPresenterProtocol,
         router: FinalRouterProtocol,
         ratingManager: RatingManagerProtocol,
         profileManager: ProfileServicesManagerProtocol) {
        finalists = []
        finalistProfileImages = []

        self.presenter = presenter
        self.router = router
        self.ratingManager = ratingManager
        self.profileManager = profileManager
    }
}

// MARK: - FinalInteractorProtocol

extension FinalInteractor: FinalInteractorProtocol {
    func processTransitionToProfile(in position: Int) {
        let finalist = finalists[position].translatedToUserProfile()
        let image = finalistProfileImages[position]
        router.routeToProfile(for: finalist, profileImage: image)
    }
    
    func setupInitialData() {
        getLink()
        fetchSemifinalists()
    }

    func sendVote() {
        // TODO: Сервис по отправке голоса
    }
}

// MARK: - Private Methods

private extension FinalInteractor {

    func getLink() {
        // TODO: добавить сервис по получению ссылки на трансляцию и таймер
        guard let link = URL(string: "https://vk.com/video_ext.php?oid=-182191338&id=456239464&hash=e0d018b5e535304f")
            else { return }
        let timer = Date()
        presenter.presentStreamingVideo(link: link, timer: timer)
    }

    func fetchSemifinalists() {
        ratingManager.fetchFinalists { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let finalists):
                self.finalists = finalists
                self.finalistProfileImages = Array(repeating: nil, count: finalists.count)
                self.presenter.present(finalists: finalists)
                self.loadFinalistsProfileImages(for: finalists)
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
