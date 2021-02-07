//
//  RatingsService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 30.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol RatingsServiceProtocol {
    
    typealias Complition = (Result<[RatingProfile], NetworkErrors>) -> Void

    func fetchRatings(completion: @escaping Complition)
}

final class RatingsService {

    // MARK: - Private Properties

    private static let numberOfItems = "200"

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let getRatings = "get"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case number
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }
}

// MARK: - SemifinalServiceProtocol

extension RatingsService: RatingsServiceProtocol {
    func fetchRatings(completion: @escaping Complition) {
        let headers = ["Authorization": Globals.user.token]
        let parameters = [ParametersKeys.number.rawValue: RatingsService.numberOfItems]
        let request = Request<[RatingProfile]>(path: basePath + "/" + Path.getRatings,
                                             type: .urlParameters(parameters),
                                             headers: headers)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let battleModels = response as? [RatingProfile] else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(battleModels))
            case .failure(let error):
                guard let error = error as? NetworkErrors else {
                    completion(.failure(.default))
                    return
                }
                completion(.failure(error))
            }
        }
    }
}
