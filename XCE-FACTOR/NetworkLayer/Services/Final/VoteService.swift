//
//  VoteService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 26.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol VoteServiceProtocol {
    
    typealias Complition = (Result<Bool, NetworkErrors>) -> Void

    func addVote(for finalistId: Int, completion: @escaping Complition)
}

final class VoteService {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let addVote = "vote"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }
}

// MARK: - SemifinalServiceProtocol

extension VoteService: VoteServiceProtocol {
    func addVote(for finalistId: Int, completion: @escaping  (Result<Bool, NetworkErrors>) -> Void) {
        let headers = ["Authorization": Globals.user.token]
        let request = Request<Bool>(path: basePath + "/" + Path.addVote,
                                    type: .bodyParameter(finalistId),
                                    httpMethod: .post,
                                    headers: headers)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let battleModels = response as? Bool else {
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
