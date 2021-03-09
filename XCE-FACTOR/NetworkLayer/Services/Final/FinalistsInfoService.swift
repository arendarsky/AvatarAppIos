//
//  FinalistsInfoService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 26.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol FinalistsInfoServiceProtocol {
    
    typealias Complition = (Result<FinalModel, NetworkErrors>) -> Void

    func fetchFinalistsInfo(completion: @escaping Complition)
}

final class FinalistsInfoService {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let getFinalModel = "get"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }
}

// MARK: - SemifinalServiceProtocol

extension FinalistsInfoService: FinalistsInfoServiceProtocol {
    func fetchFinalistsInfo(completion: @escaping Complition) {
        let headers = ["Authorization": Globals.user.token]
        let request = Request<FinalModel>(path: basePath + "/" + Path.getFinalModel,
                                          type: .default,
                                          headers: headers,
                                          checkStatusCode: 204)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let finalModel = response as? FinalModel else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(finalModel))
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
