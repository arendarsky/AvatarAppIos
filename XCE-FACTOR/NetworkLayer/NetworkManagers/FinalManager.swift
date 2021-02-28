//
//  FinalManager.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 26.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol FinalManagerProtocol {

    typealias Complition = (Result<FinalModel, NetworkErrors>) -> Void

    func fetchFinalInfo(completion: @escaping Complition)

    func addVote(for finalistId: Int, completion: @escaping (Result<Bool, NetworkErrors>) -> Void)
}

/// Менеджер отвечает за логику в сервисах финала
final class FinalManager {

    // MARK: - Private Properties

    private let finalistsInfoService: FinalistsInfoServiceProtocol
    private let voteService: VoteServiceProtocol

    private struct Path {
        static let basePath = "/api/final"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol) {
        voteService = VoteService(networkClient: networkClient, basePath: Path.basePath)
        finalistsInfoService = FinalistsInfoService(networkClient: networkClient, basePath: Path.basePath)
    }
}

// MARK: - Authentication Manager Protocol

extension FinalManager: FinalManagerProtocol {
    func addVote(for finalistId: Int, completion: @escaping (Result<Bool, NetworkErrors>) -> Void) {
        voteService.addVote(for: finalistId, completion: completion)
    }
    
    func fetchFinalInfo(completion: @escaping Complition) {
        finalistsInfoService.fetchFinalistsInfo(completion: completion)
    }
}

