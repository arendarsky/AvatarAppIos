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

    // MARK: - IBOutlets

    @IBOutlet private weak var descriptionNavItem: UINavigationItem!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var symbolCounter: UILabel!
    @IBOutlet private weak var saveButton: UIBarButtonItem!

    // MARK: - Public Properties
    
    weak var parentVC: ProfileViewController?
    var descriptionText: String = ""

    // MARK: - Private Properties

    private let symbolLimit = 200
    private let activityIndicator = UIActivityIndicatorView()

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private let profileManager = ProfileServicesManager(networkClient: NetworkClient())
    private var alertFactory: AlertFactoryProtocol?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
        alertFactory = AlertFactory(viewController: self)

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

    // MARK: - IBActions

    @IBAction private func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonPressed(_ sender: Any) {
        saveChangesAndDismiss()
    }
}
// MARK: - Private Methods

private extension EditDescriptionVC {
    func configureViews() {
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
    
    func saveChangesAndDismiss() {
        descriptionText = descriptionTextView.text
        guard descriptionText.count <= symbolLimit else {
            alertFactory?.showAlert(type: .descriptionIsTooLong)
            return
        }
        descriptionText = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        activityIndicator.enableInNavBar(of: descriptionNavItem)

        profileManager.set(description: descriptionText) { result in
            switch result {
            case .failure(let error):
                self.alertFactory?.showAlert(type: .connectionToServerError)
            case .success:
                 self.parentVC?.profileUserInfo.descriptionTextView.text = self.descriptionText
                 self.parentVC?.disableEditMode()
                 self.parentVC?.updateData(isPublic: false)
                 
                 self.dismiss(animated: true) {
                     self.parentVC?.profileCollectionView.reloadData()
                 }
            }
        }
    }
}

// MARK: - UI Text View Delegate

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
