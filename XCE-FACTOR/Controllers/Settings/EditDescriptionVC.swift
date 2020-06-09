//
//MARK:  EditDescriptionVC.swift
//  XCE-FACTOR
//
//  Created by Владислав on 07.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class EditDescriptionVC: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    let symbolLimit = 200
    var descriptionText: String = ""
    
    let activityIndicator = UIActivityIndicatorView()
    weak var parentVC: ProfileViewController?
    
    @IBOutlet weak var descriptionNavItem: UINavigationItem!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var symbolCounter: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        presentationController?.delegate = self
        configureViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //MARK:- Attempt to Dismiss
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showActionSheetWithOptions(title: nil, buttons: [
            UIAlertAction(title: "Сохранить", style: .default, handler: { (saveAction) in
                self.saveChangesAndDismiss()
            }),
            UIAlertAction(title: "Отменить изменения", style: .default, handler: { (discardAction) in
                self.dismiss(animated: true, completion: nil)
            })
        ])
    }

    //MARK:- Cancel Button Pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Save Button Pressed
    @IBAction private func saveButtonPressed(_ sender: Any) {
        saveChangesAndDismiss()
    }
    
    //MARK:- Configure Views
    private func configureViews() {
        descriptionTextView.cornerRadiusV = 10
        descriptionTextView.borderColorV = UIColor.white.withAlphaComponent(0.7)
        descriptionTextView.borderWidthV = 0.5
        
        descriptionTextView.text = descriptionText
        descriptionTextView.delegate = self
        symbolCounter.text = "\(descriptionTextView.text.count)/\(symbolLimit)"
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.descriptionTextView.becomeFirstResponder()
        //}
    }
    
    //MARK:- Save Changes
    func saveChangesAndDismiss() {
        descriptionText = descriptionTextView.text
        guard descriptionText.count <= symbolLimit else {
            showIncorrectUserInputAlert(title: "Описание слишком длинное", message: "")
            return
        }
        descriptionText = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        activityIndicator.enableInNavBar(of: descriptionNavItem)
        Profile.setDescription(newDescription: descriptionText) { (sessionResult) in
            self.activityIndicator.disableInNavBar(of: self.descriptionNavItem, replaceWithButton: self.saveButton)
            
            switch sessionResult {
            case.error(let error):
                print(error)
                self.showErrorConnectingToServerAlert()
            case .results(let statusCode):
                if statusCode == 200 {
                    self.parentVC?.profileUserInfo.descriptionTextView.text = self.descriptionText
                    self.parentVC?.disableEditMode()
                    self.parentVC?.updateData(isPublic: false)
                    self.dismiss(animated: true)
                } else {
                    self.showErrorConnectingToServerAlert()
                }
            }
        }
    }
    
}

//MARK:- Text View Delegate
extension EditDescriptionVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.count <= symbolLimit {
            textView.borderColorV = UIColor.white.withAlphaComponent(0.7)
            if #available(iOS 13.0, *) {
                symbolCounter.textColor = .placeholderText
            } else {
                symbolCounter.textColor = .lightGray
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        symbolCounter.text = "\(textView.text.count)/\(symbolLimit)"
        //descriptionPlaceholder.isHidden = textView.text.count != 0
        if textView.text.count > symbolLimit {
            textView.borderColorV = .systemRed
            symbolCounter.textColor = .systemRed
        } else {
            textView.borderColorV = UIColor.white.withAlphaComponent(0.7)
            if #available(iOS 13.0, *) {
                symbolCounter.textColor = .placeholderText
            } else {
                symbolCounter.textColor = .lightGray
            }
        }
    }
}
