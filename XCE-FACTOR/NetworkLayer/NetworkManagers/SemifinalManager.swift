//
//  SemifinalManager.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 29.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol SemifinalManagerProtocol {

    typealias Complition = (Result<[BattleModel], NetworkErrors>) -> Void

    func fetchSemifinalBattles(completion: @escaping Complition)
}

/// Менеджер отвечает за логику в сервисах полуфинала
final class SemifinalManager {

    // MARK: - Private Properties

    private let battlesService: BattlesServiceProtocol

    private struct Path {
        static let basePath = "/api/semifinal"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol) {
        battlesService = BattlesService(networkClient: networkClient, basePath: Path.basePath)
    }
}

// MARK: - Authentication Manager Protocol

extension SemifinalManager: SemifinalManagerProtocol {
    func fetchSemifinalBattles(completion: @escaping (Result<[BattleModel], NetworkErrors>) -> Void) {
        battlesService.fetchSemifinalBattles(completion: completion)
    }
}
