//
//  SemifinalistsService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 30.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol SemifinalistsServiceProtocol {
    
    typealias Complition = (Result<[RatingProfile], NetworkErrors>) -> Void

    func fetchSemifinalists(completion: @escaping Complition)
}

final class SemifinalistsService {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let getSemifinalists = "get_semifinalists"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }
}

// MARK: - SemifinalServiceProtocol

extension SemifinalistsService: SemifinalistsServiceProtocol {
    func fetchSemifinalists(completion: @escaping Complition) {
        let headers = ["Authorization": Globals.user.token]
        let request = Request<[RatingProfile]>(path: basePath + "/" + Path.getSemifinalists,
                                               type: .default,
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
