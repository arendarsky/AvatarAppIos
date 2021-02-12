//
//  FinalistsService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 08.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol FinalistsServiceProtocol {
    
    typealias Complition = (Result<[RatingProfile], NetworkErrors>) -> Void

    func fetchFinalists(completion: @escaping Complition)
}

final class FinalistsService {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let getFinalists = "get_finalists"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }
}

// MARK: - SemifinalServiceProtocol

extension FinalistsService: FinalistsServiceProtocol {
    func fetchFinalists(completion: @escaping Complition) {
        let headers = ["Authorization": Globals.user.token]
        let request = Request<[RatingProfile]>(path: basePath + "/" + Path.getFinalists,
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
