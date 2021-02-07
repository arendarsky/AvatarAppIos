//
//  FinalRouter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

protocol FinalRouterProtocol {
    func showError(_ error: Error)
}

final class FinalRouter {

    weak var viewController: FinalViewControllerProtocol?
}

// MARK: - FinalRouterProtocol

extension FinalRouter: FinalRouterProtocol {
    func showError(_ error: Error) {}
}
