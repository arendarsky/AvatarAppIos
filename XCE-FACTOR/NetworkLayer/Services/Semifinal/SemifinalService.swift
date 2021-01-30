//
//  SemifinalService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 29.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol SemifinalServiceProtocol {
    
    typealias Complition = (Result<[BattleModel], NetworkErrors>) -> Void

    func fetchSemifinalBattles(completion: @escaping Complition)
}

final class SemifinalService {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let getBattles = "battles/get"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }
}

// MARK: - SemifinalServiceProtocol

extension SemifinalService: SemifinalServiceProtocol {
    func fetchSemifinalBattles(completion: @escaping Complition) {
        let headers = ["Authorization": Globals.user.token]
        let request = Request<[BattleModel]>(path: basePath + "/" + Path.getBattles,
                                             type: .default,
                                             headers: headers)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let battleModels = response as? [BattleModel] else {
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
