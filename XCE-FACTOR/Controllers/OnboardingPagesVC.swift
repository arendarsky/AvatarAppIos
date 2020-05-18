//
//MARK:  OnboardingPagesVC.swift
//  XCE-FACTOR
//
//  Created by Владислав on 17.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import PaperOnboarding

class OnboardingPagesVC: UIViewController {

    @IBOutlet weak var onboarding: PaperOnboarding!
    @IBOutlet weak var startButton: XceFactorWideButton!
    
    var pages = [OnboardingItemInfo]()
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePages()
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    //MARK:- Configure Pages
    func configurePages() {
        let textColor = UIColor.label
        let pageBackgrndColor = UIColor.systemBackground
        let pageIcon = UIImage(systemName: "circle.fill")!
        
        pages = [
            OnboardingItemInfo(informationImage: UIImage(named: "LogoIcon")!,
            title: "XCE FACTOR",
            description: "Это первое в мире шоу таланта без жюри. Любой может показать свой талант на большую аудиторию и получить возможность выступить в шоу с трансляцией на 500 000 человек. Победитель получает главный приз по результатам зрительского голосования.",
            pageIcon: pageIcon, color: pageBackgrndColor, titleColor: textColor, descriptionColor: textColor,
            titleFont: .boldSystemFont(ofSize: 30), descriptionFont: .systemFont(ofSize: 18)),
            
            OnboardingItemInfo(informationImage: UIImage(systemName: "info.circle")!,
            title: "Информация",
            description: "На каждой странице есть значок ⓘ.\nНажав на него, ты всегда можешь прочитать, что нужно делать, чтобы выиграй или получить максимум удовольствия от игры.",
            pageIcon: pageIcon, color: pageBackgrndColor, titleColor: textColor, descriptionColor: textColor,
            titleFont: .boldSystemFont(ofSize: 30), descriptionFont: .systemFont(ofSize: 18))
        ]
        
        onboarding.delegate = self
        onboarding.dataSource = self
    }

}

//MARK:- PaperOnboarding Delegate
extension OnboardingPagesVC: PaperOnboardingDelegate {
    
}

//MARK:- PaperOnboarding Data Source
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
