//
//  RatingManager.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 30.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol RatingManagerProtocol {

    typealias Complition = (Result<[RatingProfile], NetworkErrors>) -> Void

    func fetchRatings(completion: @escaping Complition)

    func fetchSemifinalists(completion: @escaping Complition)

    func fetchFinalists(completion: @escaping Complition)
}

/// Менеджер отвечает за логику в сервисах полуфинала
final class RatingManager {

    // MARK: - Private Properties

    private let ratingsService: RatingsServiceProtocol
    private let semifinalistsService: SemifinalistsServiceProtocol
    private let finalistsService: FinalistsServiceProtocol

    private struct Path {
        static let basePath = "/api/rating"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol) {
        ratingsService = RatingsService(networkClient: networkClient, basePath: Path.basePath)
        semifinalistsService = SemifinalistsService(networkClient: networkClient, basePath: Path.basePath)
        finalistsService = FinalistsService(networkClient: networkClient, basePath: Path.basePath)
    }
}

// MARK: - Authentication Manager Protocol

extension RatingManager: RatingManagerProtocol {

    func fetchRatings(completion: @escaping Complition) {
        ratingsService.fetchRatings(completion: completion)
    }

    func fetchSemifinalists(completion: @escaping Complition) {
        semifinalistsService.fetchSemifinalists(completion: completion)
    }

    func fetchFinalists(completion: @escaping Complition) {
        finalistsService.fetchFinalists(completion: completion)
    }
}
