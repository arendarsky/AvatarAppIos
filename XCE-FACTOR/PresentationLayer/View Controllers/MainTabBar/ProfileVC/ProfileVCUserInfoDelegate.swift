//
//MARK:  ProfileVCUserInfoDelegate.swift
//  XCE-FACTOR
//
//  Created by Владислав on 13.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit


extension ProfileViewController: ProfileUserInfoViewDelegate {
    //MARK:- Did Tap on Description
    func didTapOnDescriptionView(_ textView: UITextView) {
        guard isEditProfileDataMode else {
            return
        }
        performSegue(withIdentifier: "Edit Description", sender: textView)
    }
    
    //MARK:- Did Press Instagram Button
    func didPressInstagramButton(_ sender: UIButton) {
        openInstagramIfSet()
    }
    
    func didPressCopyButton() {
        UIPasteboard.general.string = userData.instagramLogin
    }
    
    func didPressEditInstagramButton() {
        editInstagramAccount()
    }
    
}

extension ProfileViewController {
    func editInstagramAccount() {
        showAlertWithTextField(title: "Привязать Instagram", message: "Если у Вас есть аккаунт в Instagram, то здесь Вы можете ввести имя своего профиля и добавить его", textFieldText: userData.instagramLogin, placeholder: "@xcefactor", textAlignment: .center, okTitle: "Сохранить") { (textFieldText) in
            var nickname = textFieldText.trimmingCharacters(in: .whitespaces)
            if let index = nickname.firstIndex(of: "@") {
                nickname.remove(at: index)
                nickname = nickname.trimmingCharacters(in: .whitespaces)
            }
            //print(nickname)
            self.uploadChanges(name: self.userData.name, description: self.userData.description ?? "", instagramNickname: nickname, endEditing: false)
        }
    }
    
    func openInstagramIfSet() {
        if let nickname = userData.instagramLogin, nickname != "", !isEditProfileDataMode {
            ShareManager.openInstagramProfile(nickname)
        } else if isPublic {
            showSimpleAlert(title: "Нет Instagram", message: "У этого пользователя не привязан аккаунт Instagram")
        } else {
            editInstagramAccount()
        }
    }
}

extension ProfileViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return MenuManager.instagramProfileMenuConfig(self, isPublic: isPublic, userData: userData)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.openInstagramIfSet()
        }
    }
}
