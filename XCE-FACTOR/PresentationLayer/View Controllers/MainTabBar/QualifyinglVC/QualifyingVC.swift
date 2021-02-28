//
//  QualifyingVC.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 28.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

final class QualifyingAssembly {
    static func build() -> UIViewController {
        return QualifyingVC()
    }
}

final class QualifyingVC: UIViewController {

    // MARK: - Private Properties

    private let segment: UISegmentedControl = UISegmentedControl(items: ["Полуфинал", "Финал"])

    // MARK: - Private Lazy Properties

    private lazy var semifinalViewController: SemifinalVC = {
        let controller = SemifinalAssembly.build()
        add(childVC: controller)

        return controller as! SemifinalVC
    }()

    private lazy var finalViewController: FinalViewController = {
        let controller = FinalAssembly.build()
        add(childVC: controller)

        return controller as! FinalViewController
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavBar()
        configureSegment()
        navigationItem.titleView = segment
    }
}

// MARK: - Private Methods

private extension QualifyingVC {
    func add(childVC viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    func remove(childVC viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    func  configureSegment() {
        segment.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        segment.selectedSegmentIndex = 0

        updateSegment()
    }

    func updateSegment() {
        switch segment.selectedSegmentIndex {
        case 0:
            remove(childVC: finalViewController)
            add(childVC: semifinalViewController)
        case 1:
            remove(childVC: semifinalViewController)
            add(childVC: finalViewController)
        default: break
        }
    }

    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateSegment()
    }
}
