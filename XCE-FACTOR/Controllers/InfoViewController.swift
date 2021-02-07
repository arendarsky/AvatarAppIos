//
//  InfoViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

final class InfoViewController: XceFactorViewController {

    enum InfoType {
        case profile
        case rating
        case casting
        case notifications
    }

    // MARK: - IBOutlets

    @IBOutlet weak var infoHeader: UILabel!
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var dismissButton: MainButton!

    // MARK: - PublicProperties
    
    var header: String?
    var infoTextType: InfoType?
    var infoImage: UIImage?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    // MARK: - Private Methods

    private func configureViews() {
        view.backgroundColor = .clear
        //UIColor.systemPurple.withAlphaComponent(0.3)
        //UIColor.darkGray.withAlphaComponent(0.5)
        view.addBlur(style: .regular)
        
        infoHeader.text = header
        infoImageView.image = infoImage
        infoTextLabel.attributedText = setInfoText(of: infoTextType)

        dismissButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
    }
    
    private func setInfoText(of: InfoType?) -> NSMutableAttributedString {
        switch infoTextType {
        case .profile:
            return NSMutableAttributedString(string: "Это Ваш личный профиль. Вы можете выбрать себе аватарку, заполнить описание и загрузить видео своего таланта. Максимальное количество загруженных видео — 4.\n\nНе забудьте указать свои соцсети, чтобы пользователи могли связаться с Вами и познакомиться.\n\nЧтобы Ваше видео могли увидеть все пользователи и проголосовать за него, нажмите “•••” на видео и выберите «Отправить в кастинг». Одновременно находиться в Кастинге может только одно видео.\n\nКогда Вы заменяете видео в Кастинге, лайки за предыдущее сохраняются. Каждое видео, отправленное в Кастинг, будет показано всем пользователям один раз.\n\nГолоса, они же лайки, за все видео, отправленные в Кастинг, суммируются. Если Вы удаляете видео, то теряете полученные за него лайки.\n\nЧтобы выбрать другой 30-секундный фрагмент, нажмите “•••” на видео и выберите «Изменить фрагмент».")
        case .rating:
            return NSMutableAttributedString(string: "В Рейтинге Вы можете посмотреть видео 50 лучших талантов по мнению всех пользователей приложения. Отдать свой голос за талант в данном разделе нельзя, чтобы у топ-50 не было преимущества.\n\nЧтобы узнать подробную информацию о пользователе, нажмите на аватарку. Вам откроется его/ее профиль.\n\nКак в Рейтинге, так и в остальных разделах Вы можете два раза нажать на видео, чтобы изменить его размер.")
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
        case .none:
            return NSMutableAttributedString(string: "")
        }
    }

    // MARK: - Actions

    @objc private func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
