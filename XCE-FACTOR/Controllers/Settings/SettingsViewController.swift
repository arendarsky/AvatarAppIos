//
//  SettingsViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: XceFactorViewController {
    //MARK:- Properties
    @IBOutlet weak var passwordHeader: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailHeader: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var supportMessageLabel: UITextView!
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    //@IBOutlet weak var aboutAppLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavBar()
        configureViews()
        addTapRecognizers()
    }
    
    private func tapAction() {
        performSegue(withIdentifier: "Change Settings", sender: nil)
    }
    
    //MARK:- Exit Button Pressed
    @IBAction func exitAccountButtonPressed(_ sender: Any) {
        confirmActionAlert(title: "Выйти из аккаунта?", message: "Это завершит текущую сессию пользователя") { (action) in
            Defaults.clearUserData()
            self.setApplicationRootVC(storyboardID: "WelcomeScreenNavBar")
        }
    }

    @IBAction func policyButtonPressed(_ sender: Any) {
        openSafariVC(self, with: .privacyPolicyAtGoogleDrive, autoReaderView: true)
    }
    
}

extension SettingsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController {
    private func configureViews() {
        emailLabel.text = "     \(Globals.user.email)"
        let cornerRadius: CGFloat = 8.0
        roundTwoViewsAsOne(left: passwordHeader, right: passwordLabel, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: emailHeader, right: emailLabel, cornerRadius: cornerRadius)

        emailLabel.alpha = 0.5
        emailHeader.alpha = 0.5
        
        let attrString = NSMutableAttributedString(string: "Если у Вас есть любые вопросы или предложения, напишите нам, пожалуйста, в личные сообщения группы ВКонтакте ", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.lightGray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)
        ])
        attrString.append(NSAttributedString(string: "XCE FACTOR 2020", attributes: [
            NSAttributedString.Key.link : URL(string: "https://vk.com/xcefactor2020")!
            //NSAttributedString.Key.foregroundColor : UIColor.systemPurple
        ]))
        supportMessageLabel.attributedText = attrString
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

        versionLabel.text = "XCE FACTOR | Release \(appVersionString) (\(buildNumber))"
    }
    
    private func addTapRecognizers() {
        passwordLabel.addTapGestureRecognizer(action: tapAction)
        passwordHeader.addTapGestureRecognizer(action: tapAction)
        emailHeader.addTapGestureRecognizer {
            print("email tapped")
        }
        emailLabel.addTapGestureRecognizer {
            print("email tapped")
        }
    }
}
