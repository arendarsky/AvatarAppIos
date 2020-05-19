//
//MARK:  XceFactorViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit

///A base view controller for the app
class XceFactorViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .default } else {
            return .lightContent
        }
    }
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTheme()
        configurations()
    }
    
    //MARK:- View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handlePossibleSoundError()
    }
    
    //MARK:- Load Theme
    ///Is used now to load dark theme on iOS 12 devices
    func loadTheme() {
        self.setNeedsStatusBarAppearanceUpdate()
        if #available(iOS 13, *) {
            
        } else {
            self.view.backgroundColor = .black
        }
    }
    
    //MARK:- Configurations
    func configurations() {
        //MARK:- color of back button for the NEXT vc on stack
        navigationItem.backBarButtonItem?.tintColor = .white
    }
    
    //MARK:- Handle Possible Sound Error
    func handlePossibleSoundError() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            //try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    //MARK:- Present Onboarding Pages
    ///Presents onboarding pages
    func presentOnboardingVC(relatedTo condition: Bool) {
        if condition, let vc = storyboard?.instantiateViewController(withIdentifier: "OnboardingPagesVC") as? OnboardingPagesVC {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(vc, animated: true)
            }
        }
    }
    
    //MARK:- Show Info View Controller
    func presentInfoViewController(withHeader header: String?, text: InfoText, image: UIImage? = nil) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController {
            vc.header = header
            vc.infoImage = image
            vc.infoText = text.attrText
            
            vc.modalPresentationStyle = .automatic
            present(vc, animated: true)
        }
    }
    
    enum InfoText {
        case profile
        case rating
        case casting
        case notifications
        
        var attrText: NSMutableAttributedString {
            switch self {
            case .profile:
                return NSMutableAttributedString(string: "Это Ваш личный профиль. Вы можете выбрать себе аватарку, заполнить описание и загрузить видео своего таланта. Максимальное количество загруженных видео — 4.\n\nНе забудьте указать свои соцсети, чтобы пользователи могли связаться с Вами и познакомиться.\n\nЧтобы Ваше видео могли увидеть все пользователи и проголосовать за него, нажмите “•••” на видео и выберите «Отправить в кастинг». Одновременно находиться в Кастинге может только одно видео.\n\nКогда Вы заменяете видео в Кастинге, лайки за предыдущее сохраняются. Каждое видео, отправленное в Кастинг, будет показано всем пользователям один раз.\n\nГолоса, они же лайки, за все видео, отправленные в Кастинг, суммируются. Если Вы удаляете видео, то теряете полученные за него лайки.\n\nЧтобы выбрать другой 30-секундный фрагмент, нажмите “•••” на видео и выберите «Изменить фрагмент».")
            case .rating:
                return NSMutableAttributedString(string: "В Рейтинге Вы можете посмотреть видео 20 лучших талантов по мнению всех пользователей приложения. Отдать свой голос за талант в данном разделе нельзя, чтобы у топ-20 не было преимущества.\n\nЧтобы узнать подробную информацию о пользователе, нажмите на аватарку. Вам откроется его/ее профиль.\n\nКак в Рейтинге, так и в остальных разделах Вы можете два раза нажать на видео, чтобы изменить его размер.")
            case .casting:
                let highlightAttributes = [
                    NSAttributedString.Key.foregroundColor : UIColor.systemPurple
                ]
                let heart = NSAttributedString(string: "♡", attributes: highlightAttributes)
                let xmark = NSAttributedString(string: "✕", attributes: highlightAttributes)
                let castingInfo = NSMutableAttributedString(string: "В Кастинге все пользователи голосуют за видео с талантами. Если Вы хотите видеть талант в финале шоу XCE FACTOR 2020, нажмите “")
                castingInfo.append(heart)
                castingInfo.append(NSAttributedString(string: "” или свайпните вправо. Если Вы хотите пропустить видео, нажмите “"))
                castingInfo.append(xmark)
                castingInfo.append(NSAttributedString(string: "” или свайпните влево.\n\nСвайп вправо приносит пользователю 1 лайк, свайп влево — меняет видео с текущего на следующее, не вычитая лайков.\n\nЧтобы узнать подробную информацию о пользователе, нажмите на аватарку. Вам откроется его/ее профиль.\n\nЧтобы загрузить свое видео в Кастинг, нажмите “＋” в правом верхнем углу. Оно быстро пройдет модерацию. В Кастинг попадают видео, на которых пользователь показывает талант и не нарушает законодательство РФ."))
                return castingInfo
                
            case .notifications:
                return NSMutableAttributedString(string: "Если Вы отправили видео в Кастинг, здесь Вы можете увидеть, какие пользователи проголосовали за Вас.\n\nЧтобы узнать подробную информацию о пользователе, нажмите на аватарку. Вам откроется его/ее профиль.")
            }
        }
    }

}
