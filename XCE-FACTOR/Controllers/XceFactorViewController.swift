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

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTheme()
        handlePossibleSoundError()
    }
    
    //MARK:- Load Theme
    func loadTheme() {
        self.setNeedsStatusBarAppearanceUpdate()
        if #available(iOS 13, *) {
            
        } else {
            self.view.backgroundColor = .black
        }
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
    
    //MARK:- Show Info View Controller
    func presentInfoViewController(withHeader header: String?, text: String?, image: UIImage? = nil) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController {
            vc.header = header
            vc.infoText = text
            vc.infoImage = image
            
            vc.modalPresentationStyle = .automatic
            present(vc, animated: true)
        }
    }
    
//    enum InfoText: String {
//        case profile = "Это ваш личный профиль. Вы можете выбрать себе аватарку, заполнить описание и загрузить видео своего таланта. Максимальное количество загруженных видео — 4. Не забудьте указать свои соцсети, чтобы пользователи могли связаться с вами и познакомиться. Чтобы ваше видео могли увидеть все пользователи и проголосовать за него, нажмите “ ” на видео и выберите «Отправить в кастинг». Одновременно находиться в Кастинге может только одно видео. Когда вы заменяете видео в Кастинге, лайки за предыдущее сохраняются. Каждое видео, отправленное в Кастинг, будет показано всем пользователям один раз. Голоса, они же лайки, за все видео, отправленные в Кастинг, суммируются. Если вы удаляете видео, то теряете полученные за него лайки. Чтобы выбрать другой 30-секундный фрагмент, нажмите “ ” на видео и выберите «Изменить фрагмент»."
//    }

}
