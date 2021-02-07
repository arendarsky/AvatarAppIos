//
//  XCE-FACTOR
//
//  Created by Владислав on 17.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import PaperOnboarding

class OnboardingPagesVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var onboarding: PaperOnboarding!
    @IBOutlet private weak var startButton: MainButton!

    // MARK: - Private Properties

    private var pages = [OnboardingItemInfo]()

    // MARK: - Public Properties

    weak var parentVC: UIViewController?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        configurePages()
        
    }
    
    // MARK: - Private Methods

    private func configurePages() {
        let textColor = UIColor.label
        let pageBackgrndColor = UIColor.systemBackground
        let pageIcon = UIImage(systemName: "circle.fill")!
        let titleFont = UIFont(name: "Quantico-Bold", size: 30)! //UIFont.boldSystemFont(ofSize: 30)
        let textFont = UIFont.systemFont(ofSize: 18)

        pages = [
            OnboardingItemInfo(informationImage: UIImage(named: "LogoIcon")!,
            title: "XCE FACTOR",
            description: "Это первое в мире шоу талантов без жюри. Любой может показать свой талант на широкую аудиторию и получить возможность выступить в шоу с трансляцией на 500 000 человек. Победитель получает главный приз по результатам зрительского голосования",
            pageIcon: pageIcon, color: pageBackgrndColor, titleColor: textColor, descriptionColor: textColor,
            titleFont: titleFont, descriptionFont: textFont),
            
            OnboardingItemInfo(informationImage: UIImage(systemName: "info.circle")!,
            title: "Информация",
            description: "На каждой странице есть значок ⓘ.\nНажав на него, Вы всегда можете узнать, что нужно делать, чтобы выиграть или получить максимум удовольствия от игры",
            pageIcon: pageIcon, color: pageBackgrndColor, titleColor: textColor, descriptionColor: textColor,
            titleFont: titleFont, descriptionFont: textFont)
        ]
        
        onboarding.delegate = self
        onboarding.dataSource = self
    }

    private func configureButton() {
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func startButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK: - PaperOnboarding Delegate

extension OnboardingPagesVC: PaperOnboardingDelegate {
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        item.imageView?.tintColor = .systemPurple
        
        if UIScreen.main.nativeBounds.width == 640 {
            item.descriptionLabel?.adjustsFontSizeToFitWidth = true
            item.titleCenterConstraint?.constant -= 50
            item.titleLabel?.font = item.titleLabel?.font.withSize(24)
            item.descriptionLabel?.font = item.descriptionLabel?.font.withSize(14)
        }
    }
}

// MARK: - PaperOnboarding Data Source

extension OnboardingPagesVC: PaperOnboardingDataSource {
    func onboardingItemsCount() -> Int {
        pages.count
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        pages[index]
    }
    
    func onboardinPageItemRadius() -> CGFloat {
        return 5
    }
    
    func onboardingPageItemSelectedRadius() -> CGFloat {
        return 10
    }
    
}
