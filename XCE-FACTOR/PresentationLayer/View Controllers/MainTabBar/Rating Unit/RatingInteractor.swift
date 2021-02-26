//	RatingInteractor.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 06.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// Протокол интерактора экрана Рейтинга
protocol RatingInteractorProtocol {
    /// Загрузка начального состояния экрана
    func setupInitialData()
    
    /// Обновить дату
    func refreshData()
    
    /// Обработать переход в другой экран
    /// - Parameters:
    ///   - type: Тип секции на экране рейтинга
    ///   - position: Положение в ряду
    func processTransition(for type: RatingViewController.RatingType, in position: Int)

    /// Обработать переход в другой экран
    /// - Parameters:
    ///   - type: Тип секции на экране рейтинга
    ///   - position: Положение в ряду
    func processSharing(for type: RatingViewController.RatingType, in position: Int)
}

/// Интерактор экрана Рейтинга
final class RatingInteractor {

    static let topNumber = 50

    // MARK: - Private Properties

    private var finalists: [RatingProfile] = []
    private var semifinalists: [RatingProfile] = []
    private var starsTop: [RatingProfile] = []

    private var cachedFinalistsImages: [UIImage?] = []
    private var cachedSemifinalistsImages: [UIImage?] = []
    private var cachedStarsTopImages: [UIImage?] = []

	private let presenter: RatingPresenterProtocol
    private let router: RatingRouterProtocol
    private let ratingManager: RatingManagerProtocol
    private let profileManager: ProfileServicesManagerProtocol

    // MARK: - Init

    /// Инициализатор
    ///
    /// - Parameters:
    ///   - presenter: Презентер экрана Рейтинга
    ///   - router: Роутер экрана Рейтинга
    ///   - ratingManager: Network-manager для взаимодействия с сервисами рейтинга
    ///   - profileManager: Network-manager для взаимодействия с сервисами профиля
	init(presenter: RatingPresenterProtocol,
         router: RatingRouterProtocol,
         ratingManager: RatingManagerProtocol,
         profileManager: ProfileServicesManagerProtocol) {
		self.presenter = presenter
        self.router = router
        self.ratingManager = ratingManager
        self.profileManager = profileManager
	}
}

// MARK: - RatingInteractorProtocol

extension RatingInteractor: RatingInteractorProtocol {
    
    func setupInitialData() {
        updateDate()
    }

    func refreshData() {
        updateDate()
    }

    func processTransition(for type: RatingViewController.RatingType, in position: Int) {
        var userProfile: UserProfile
        var profileImage: UIImage? = nil

        switch type {
        case .finalists:
            userProfile = finalists[position].translatedToUserProfile()
            if let image = cachedFinalistsImages[position] {
                profileImage = image
            }
        case .semifinalists:
            userProfile = semifinalists[position].translatedToUserProfile()
            if let image = cachedSemifinalistsImages[position] {
                profileImage = image
            }
        case .topList:
            userProfile = starsTop[position].translatedToUserProfile()
            if let image = cachedStarsTopImages[position] {
                profileImage = image
            }
        }

        router.routeToProfileVC(for: userProfile, profileImage: profileImage)
    }

    func processSharing(for type: RatingViewController.RatingType, in position: Int) {
        guard let video = starsTop[position].video?.translatedToVideoType(), type == .topList else { return }
        router.shareVideo(video)
    }
}

// MARK: - Private Methods

private extension RatingInteractor {

    func updateDate() {
        updateRatingItems()
        updateSemifinalists()
        updateFinalists()
    }

    // MARK: - Network Logic

    /// Загружаем список финалистов
    func updateFinalists() {
        ratingManager.fetchFinalists { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let finalists):
                self.finalists = finalists
                self.cachedFinalistsImages = Array(repeating: nil, count: finalists.count)

                self.loadAllProfileImages(for: finalists, type: .finalists)

                if !finalists.isEmpty, !self.starsTop.isEmpty {
                    self.presenter.addSection(for: .finalists,
                                              finalists: self.finalists,
                                              semifinalists: self.semifinalists,
                                              finalistsImages: self.cachedFinalistsImages,
                                              semifinalistsImages: self.cachedSemifinalistsImages)
                }
            case .failure: break
            }
        }
    }

    /// Загружаем список полуфиналистов
    func updateSemifinalists() {
        ratingManager.fetchSemifinalists { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let semifinalists):
                self.semifinalists = semifinalists
                self.cachedSemifinalistsImages = Array(repeating: nil, count: semifinalists.count)

                self.loadAllProfileImages(for: semifinalists, type: .semifinalists)

                if !semifinalists.isEmpty, !self.starsTop.isEmpty {
                    self.presenter.addSection(for: .semifinalists,
                                              finalists: self.finalists,
                                              semifinalists: self.semifinalists,
                                              finalistsImages: self.cachedFinalistsImages,
                                              semifinalistsImages: self.cachedSemifinalistsImages)
                }
            case .failure: break
            }
        }
    }
    
    /// Загружаем список топ-рейтинга
    func updateRatingItems() {
        ratingManager.fetchRatings { [weak self] result in
            guard let self = self else { return }
            
            /// Dismiss Refresh Control
            self.presenter.stopLoading()

            switch result {
            case .success(let profileRatings):
                var newTop: [RatingProfile] = []
                var newVideoUrls: [URL?] = []
                
                for userInfo in profileRatings {
                    if let _ = userInfo.video, newTop.count < RatingInteractor.topNumber {
                        newTop.append(userInfo)
                        newVideoUrls.append(userInfo.video?.translatedToVideoType().url)
                    }
                }
                /// Update Users and Videos List
                if newTop.count > 0 {
                    self.starsTop = newTop
                    self.cachedStarsTopImages = Array(repeating: nil, count: RatingInteractor.topNumber)
                    self.loadAllProfileImages(for: newTop, type: .topList)

                    self.presenter.presentInitialItems(finalists: self.finalists,
                                                       semifinalists: self.semifinalists,
                                                       topLists: self.starsTop,
                                                       finalistsImages: self.cachedFinalistsImages,
                                                       semifinalistsImages: self.cachedSemifinalistsImages,
                                                       starsTopImages: self.cachedStarsTopImages)
                } else {
                    self.presenter.presentNotification(isServerError: false)
                }
            case .failure:
                guard self.starsTop.count == 0 else { return }
                self.presenter.presentNotification(isServerError: true)
            }
        }
    }

    func loadAllProfileImages(for models: [RatingProfile], type: RatingViewController.RatingType) {
        for (index, user) in models.enumerated() {
            guard let imageName = user.profilePhoto else { return }

            profileManager.getImage(for: imageName) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let image):

                    switch type {
                    case .finalists:
                        self.cachedFinalistsImages[index] = image
                    case .semifinalists:
                        self.cachedSemifinalistsImages[index] = image
                    case .topList:
                        self.cachedStarsTopImages[index] = image
                    }

                    self.presenter.setProfileImage(image: image, ratingType: type, at: index)
                case .failure: break
                }
            }
        }
    }
}
