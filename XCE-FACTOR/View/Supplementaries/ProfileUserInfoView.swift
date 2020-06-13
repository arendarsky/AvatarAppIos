//
//MARK:  ProfileUserInfoView.swift
//  XCE-FACTOR
//
//  Created by Владислав on 06.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

protocol ProfileUserInfoViewDelegate: class {
    func didTapOnDescriptionView(_ textView: UITextView)
    func didPressInstagramButton(_ sender: UIButton)
}

class ProfileUserInfoView: UICollectionReusableView {
    //MARK:- Properties
    weak var delegate: ProfileUserInfoViewDelegate?
    
    let symbolLimit = 200
        
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameEditField: UITextField!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var likesDescriptionLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    
    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var symbolCounter: UILabel!
    @IBOutlet weak var instagramButton: UIButton!
    
    @IBOutlet weak var videosHeaderLabel: UILabel!
    
    //is equal to 92 in private profile and 16 in public
    @IBOutlet weak var descriptionHeaderTopConstraint: NSLayoutConstraint!
    
    //MARK:- Configure Views
    func configureViews(isProfilePublic: Bool) {
        videosHeaderLabel.isHidden = false
        
        nameEditField.isHidden = true
        nameEditField.addPadding(.both(6.0))
        nameEditField.borderColorV = UIColor.white.withAlphaComponent(0.7)
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        editImageButton.layer.cornerRadius = editImageButton.frame.width / 2
        descriptionTextView.borderWidthV = 0
        descriptionTextView.borderColorV = UIColor.white.withAlphaComponent(0.7)
        //descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 4, right: 0)
        descriptionTextView.text = ""
        //descriptionTextView.isHidden = true
        descriptionTextView.delegate = self
        descriptionTextView.addTapGestureRecognizer {
            self.didTapOnTextView()
        }
        
        if #available(iOS 13.0, *) {} else {
            likesDescriptionLabel.textColor = UIColor.lightGray.withAlphaComponent(0.5)
            nameEditField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        if isProfilePublic {
            likesNumberLabel.isHidden = true
            likesDescriptionLabel.isHidden = true
            likesImageView.isHidden = true
            
            descriptionHeaderTopConstraint.constant = 16
        }
    }
    
    //MARK:- Update Data
    func updateViews(with newData: UserProfile, updateImage: Bool = true) {
        nameLabel.text = newData.name

        if let likesNumber = newData.likesNumber {
            likesNumberLabel.text = likesNumber.formattedToLikes(.fullForm)
        }
        if let description = newData.description {
            descriptionTextView.text = description
            descriptionTextView.isHidden = false
            descriptionPlaceholder.text = "Нет описания"
            descriptionPlaceholder.isHidden = description.count > 0
        } else {
            descriptionTextView.text = ""
        }
        //profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.setProfileImage(named: newData.profilePhoto)
    }
    
    //MARK:- Check Edits
    ///- returns: `(errorMessage?, descriptionText, nameText)`
    func checkEdits() -> (String?, String, String) {
        guard descriptionTextView.text.count <= symbolLimit else {
            return ("Описание слишком длинное", "", "")
        }

        guard let nameText = nameEditField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            nameText.count != 0, nameText.count < 50 else {
                nameEditField.text = ""
                return ("Некорректное имя", "", "")
        }
        descriptionTextView.text = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        nameEditField.text = nameText
        return (nil, descriptionTextView.text, nameText)
    }

    //MARK:- Manage Edit Mode
    func setEditMode(enabled: Bool) {
        nameLabel.isHidden = enabled
        nameEditField.isEnabled = enabled
        editImageButton.isHidden = !enabled
        nameEditField.isHidden = !enabled
        nameEditField.text = nameLabel.text
        
        descriptionTextView.borderWidthV = enabled ? 1.0 : 0.0
//        descriptionTextView.isEditable = enabled
//        descriptionTextView.isSelectable = enabled
//        descriptionTextView.isScrollEnabled = enabled
//        descriptionTextView.showsVerticalScrollIndicator = enabled
        
        //symbolCounter.isHidden = !enabled
        symbolCounter.text = "\(descriptionTextView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.text = enabled ? "Расскажите о себе" : "Нет описания"
        descriptionPlaceholder.isHidden = descriptionTextView.text.count != 0
        
        if enabled {
            if #available(iOS 13.0, *) {
                descriptionTextView.backgroundColor = .systemFill
            } else {
                descriptionTextView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            }
//            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnTextView))
//            descriptionTextView.addGestureRecognizer(tapGestureRecognizer)
            
            nameEditField.becomeFirstResponder()
            //descriptionTextView.becomeFirstResponder()
        } else {
            descriptionTextView.backgroundColor = .clear
            
            //descriptionTextView.removeGestureRecognizer(descriptionTextView.gestureRecognizers!.first!)
        }
    }
    

    //MARK:- Did Tap on Text View
    @objc
    private func didTapOnTextView() {
        delegate?.didTapOnDescriptionView(descriptionTextView)
    }
    
    //MARK:- Did Press Instagram Logo
    @IBAction func didPressInstagramButton(_ sender: UIButton) {
        delegate?.didPressInstagramButton(sender)
    }
    
}

//MARK:- Text View Delegate
extension ProfileUserInfoView: UITextViewDelegate {
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
        descriptionPlaceholder.isHidden = textView.text.count != 0
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
