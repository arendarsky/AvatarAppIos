//	RatingPresenter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 06.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

// TODO: 1) Обьединить модель респонса и фотографий в одну
//       2) presentInitialItems(...) и addSection(...) объединить обшую логику в приватные методы
//       3) UIView.NotificationType - убрать логику показа из extension,
//          вынести в alertFactory или в кастомный label

/// Протокол презентера экрана Рейтинга
protocol RatingPresenterProtocol {
    /// Показать изначальные ячейки
    /// - Parameters:
    ///   - finalists: Данные финалистов
    ///   - semifinalists: Данные полуфиналистов
    ///   - topLists: Данные ТопРейтинга
    func presentInitialItems(finalists: [RatingProfile], semifinalists: [RatingProfile], topLists: [RatingProfile],
                             finalistsImages: [UIImage?], semifinalistsImages: [UIImage?], starsTopImages: [UIImage?])

    /// Установить картинку профиля в ячейку, выбранной секции
    /// - Parameters:
    ///   - image: Картинка профиля
    ///   - position: Положение в секции
    ///   - ratingType: Тип секции
    func setProfileImage(image: UIImage, ratingType: RatingViewController.RatingType, at position: Int)
    
    /// Добавить секцию финалистов/полуфиналистов
    /// - Parameters:
    ///   - type: Тип секции
    ///   - finalists: Модели финалистов
    ///   - semifinalists: Модели полуфиналистов
    ///   - finalistsImages: Фото профиля финалистов
    ///   - semifinalistsImages: Фото профиля полуфиналистов
    func addSection(for type: RatingViewController.RatingType,
                    finalists: [RatingProfile], semifinalists: [RatingProfile],
                    finalistsImages: [UIImage?], semifinalistsImages: [UIImage?])
    
    /// Показать ошибку
    func presentNotification(isServerError: Bool)

    /// Скрыть активность 
    func stopLoading()
}

/// Презентер экрана Рейтинга
final class RatingPresenter {

	weak var viewController: RatingViewControllerProtocol?
}

// MARK: - RatingPresenterProtocol

extension RatingPresenter: RatingPresenterProtocol {
    
    
    func presentInitialItems(finalists: [RatingProfile], semifinalists: [RatingProfile], topLists: [RatingProfile],
                             finalistsImages: [UIImage?], semifinalistsImages: [UIImage?], starsTopImages: [UIImage?]) {
        var index = 0
        var sections: [Int: RatingViewController.RatingType] = [:]
        var finalistModels: [StoriesCellModel] = []
        var semifinalistModels: [StoriesCellModel] = []
        var topListModels: [RatingCellModel] = []

        if !finalists.isEmpty {
            for (index, finalist) in finalists.enumerated() {
                let name = finalist.name
                let likesNumber = finalist.likesNumber
                let image = finalistsImages[index] ?? IconsManager.getIcon(.personCircleFill)!
                let model = StoriesCellModel(name: name,
                                             stroriesCellType: .likes(number: likesNumber),
                                             profileImage: image)
                finalistModels.append(model)
            }

            sections[index] = .finalists
            index += 1
        }
        
        if !semifinalists.isEmpty {
            for (index, semifinalist) in semifinalists.enumerated() {
                let name = semifinalist.name
                let likesNumber = semifinalist.likesNumber
                let image = semifinalistsImages[index] ?? IconsManager.getIcon(.personCircleFill)!
                let model = StoriesCellModel(name: name,
                                             stroriesCellType: .likes(number: likesNumber),
                                             profileImage: image)
                semifinalistModels.append(model)
            }

            sections[index] = .semifinalists
            index += 1
        }

        for (index, ratingFromTop) in topLists.enumerated() {
            let name = ratingFromTop.name
            let description = ratingFromTop.description
            let position = "#\(index + 1)"
            let likesNumber = ratingFromTop.likesNumber?.formattedToLikes(.fullForm)
            let image = starsTopImages[index] ?? IconsManager.getIcon(.personCircleFill)!
            let model = RatingCellModel(name: name,
                                        position: position,
                                        likes: likesNumber,
                                        description: description,
                                        isMuteButtonHidden: !Globals.isMuted,
                                        profileImage: image,
                                        video: ratingFromTop.video)
            topListModels.append(model)
        }

        sections[index] = .topList
        
        viewController?.displayItems(sections: sections,
                                     finalistModels: finalistModels,
                                     semifinalModels: semifinalistModels,
                                     topListModels: topListModels)
    }

    func addSection(for type: RatingViewController.RatingType,
                    finalists: [RatingProfile], semifinalists: [RatingProfile],
                    finalistsImages: [UIImage?], semifinalistsImages: [UIImage?]) {
        var index = 0
        var sections: [Int: RatingViewController.RatingType] = [:]
        var finalistModels: [StoriesCellModel] = []
        var semifinalistModels: [StoriesCellModel] = []

        if !finalists.isEmpty {
            for (index, finalist) in finalists.enumerated() {
                let name = finalist.name
                let likesNumber = finalist.likesNumber
                let image = finalistsImages[index] ?? IconsManager.getIcon(.personCircleFill)!
                let model = StoriesCellModel(name: name,
                                             stroriesCellType: .likes(number: likesNumber),
                                             profileImage: image)
                finalistModels.append(model)
            }

            sections[index] = .finalists
            index += 1
        }
        
        if !semifinalists.isEmpty {
            for (index, semifinalist) in semifinalists.enumerated() {
                let name = semifinalist.name
                let likesNumber = semifinalist.likesNumber
                let image = semifinalistsImages[index] ?? IconsManager.getIcon(.personCircleFill)!
                let model = StoriesCellModel(name: name,
                                             stroriesCellType: .likes(number: likesNumber),
                                             profileImage: image)
                semifinalistModels.append(model)
            }

            sections[index] = .semifinalists
            index += 1
        }

        sections[index] = .topList
        
        viewController?.addSection(for: type, sections: sections, finalistModels: finalistModels, semifinalModels: semifinalistModels)
    }
    
    func setProfileImage(image: UIImage, ratingType: RatingViewController.RatingType, at position: Int) {
        viewController?.setProfileImage(image, at: position, for: ratingType)
    }

    func presentNotification(isServerError: Bool) {
        let notification: UIView.NotificationType = isServerError ? .serverError : .zeroPeopleInRating
        viewController?.showError(notification)
    }

    func stopLoading() {
        viewController?.hideLoadingActivity()
    }
}
