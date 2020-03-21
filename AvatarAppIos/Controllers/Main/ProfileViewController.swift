//
//  ProfileViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import MobileCoreServices

class ProfileViewController: UIViewController {

    //MARK:- Properties
    var isPublic = false
    var isEditMode = false
    var videosData = [Video]()
    var userData = UserProfile()
    var cachedProfileImage: UIImage?
    let symbolLimit = 150
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var likesDescriptionLabel: UILabel!
    
    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var symbolCounter: UILabel!
    
    @IBOutlet weak var addNewVideoButton: UIButton!
    
    @IBOutlet weak var videosHeader: UILabel!
    @IBOutlet weak var videosContainer: UIView!
    @IBOutlet var videoViews: [ProfileVideoView]!
    @IBOutlet weak var zeroVideosLabel: UILabel!
    
    //MARK:- Profile VC Lifecycle
    ///
    ///
    
    //MARK:- • Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        updateData(isPublic: isPublic)
        configureViews()
        self.configureCustomNavBar()
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        configureRefrechControl()
        self.tabBarController?.delegate = self
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Add Video from Profile":
            let vc = segue.destination as! VideoPickVC
            vc.shouldHideViews = true
        default:
            break
        }
    }

    //MARK:- Options/Save Button Pressed
    @IBAction func optionsButtonPressed(_ sender: Any) {
        var isDescriptionSuccess = false
        if isEditMode {
            if descriptionTextView.text.count > symbolLimit {
                showIncorrectUserInputAlert(title: "Описание слишком длинное", message: "")
                
            } else {
                //MARK:- Upload Description
                Profile.setDescription(description: descriptionTextView.text) { (serverResult) in
                    switch serverResult {
                    case .error(let error):
                        print("Error: \(error)")
                        self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                    case .results(let responseCode):
                        if responseCode != 200 {
                            self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                            
                        } else {
                            isDescriptionSuccess = true
                            self.disableEditMode()
                        }
                    }
                }
                
                if cachedProfileImage == profileImageView.image {
                    if isDescriptionSuccess {
                        self.disableEditMode()
                        return
                    }
                } else {
                    
                    //MARK:- Upload Image
                    guard let imageData = self.profileImageView.image?.jpegData(compressionQuality: 0.25)
                        else {
                            return
                    }
                    let serverPath = "\(domain)/api/profile/photo/upload"
                    let headers: HTTPHeaders = [
                        "Authorization": "\(authKey)"
                    ]
                    AF.upload(multipartFormData: { (data) in
                        data.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
                    }, to: serverPath, headers: headers)
                        .response { response in
                            switch response.result {
                            case .success:
                                print("Alamofire session success")
                                let statusCode = response.response!.statusCode
                                print("upload request status code:", statusCode)
                                if statusCode != 200 {
                                    self.showErrorConnectingToServerAlert(title: "Не удалось загрузить фото", message: "Обновите экран профиля и попробуйте еще раз")
                                } else {
                                    self.disableEditMode()
                                }
                            case .failure(let error):
                                print("Alamofire session failure. Error: \(error)")
                                self.showErrorConnectingToServerAlert(title: "Не удалось загрузить фото", message: "Обновите экран профиля и попробуйте еще раз")
                            }
                    }
                }
            }
        } else {
            showOptionsAlert(
            editHandler: { (action) in
                self.enableEditMode()
                self.descriptionTextView.becomeFirstResponder()
            },
            settingsHandler: { (action) in
                //self.performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
            })
        }
    }
    
    //MARK:- Cancel Button Pressed
    @objc func cancelButtonPressed(_ sender: Any) {
        descriptionTextView.text = userData.description
        profileImageView.image = cachedProfileImage ?? UIImage(systemName: "person.crop.circle.fill")
        disableEditMode()
    }
    
    //MARK:- Edit Profile Image Button Pressed
    @IBAction func editImageButtonPressed(_ sender: Any) {
        showMediaPickAlert(mediaTypes: [kUTTypeImage], delegate: self, allowsEditing: true)
    }
    
    //MARK:- Add New Video Button Pressed
    @IBAction func addNewVideoButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Add Video from Profile", sender: sender)
    }
    
    //MARK:- Configure Refresh Control
    private func configureRefrechControl() {
        scrollView.refreshControl = nil
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
    }
    
    //MARK:- Handle Refresh Control
    @objc private func handleRefreshControl() {
        //Refreshing Data
        disableEditMode()
        updateData(isPublic: isPublic)
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            //self.nameLabel.text = self.userData.name
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK:- >>> Update Profile Data <<<
    func updateData(isPublic: Bool) {
        var id: Int? = nil
        if isPublic {
            id = self.userData.id
        }
        Profile.getData(id: id) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print(error)
            case .results(let profileData):
                DispatchQueue.main.async {
                    self.updateViewsData(newData: profileData)
                }
                
                //MARK:- Get Profile Image
                if let profileImageName = profileData.profilePhoto {
                    self.profileImageView.setProfileImage(named: profileImageName)
                    self.cachedProfileImage = self.profileImageView.image
                }

                //MARK:- Configure Videos Info
                guard let videos = profileData.videos
                else {
                    return
                }
                print(videos)
         
                self.videosData = []
                for video in videos {
                    self.videosData.append(video.translateToVideoType())
                }
                print(self.videosData)

                self.matchVideosToViews(videosData: self.videosData, isPublic: self.isPublic)
                
            }
        }
    }
    
    //MARK:- Match Videos to Video Views
    func matchVideosToViews(videosData: [Video], isPublic: Bool) {
        videosHeader.isHidden = false
        videosContainer.isHidden = false
        
        var start = 1
        if videosData.count == 4 || isPublic {
            self.addNewVideoButton.isHidden = true
            self.videoViews[0].isHidden = false
            start = 0
        }
        if videosData.count == 0 && isPublic {
            zeroVideosLabel.isHidden = false
        } else {
            zeroVideosLabel.isHidden = true
        }
        
        for i in start..<4 {
            if isPublic {
                videoViews[i].optionsButton.isHidden = true
            }
            let dataIndex = start == 0 ? i : i-1
            self.videoViews[i].delegate = self
            self.videoViews[i].index = i
            if dataIndex >= videosData.count {
                self.videoViews[i].isHidden = true
            } else {
                self.videoViews[i].isHidden = false
                if self.videoViews[i].video.name != videosData[dataIndex].name || self.videoViews[i].thumbnailImageView.image == nil {
                    self.videoViews[i].thumbnailImageView.image = nil
                    //MARK:- Get Video Thumbnail
                    VideoHelper.createVideoThumbnailFromUrl(
                        videoUrl: videosData[dataIndex].url,
                        //seconds: self.videoViews[i].video.startTime
                        timestamp: CMTime(seconds: self.videoViews[i].video.startTime, preferredTimescale: 100)) { (image) in
                            self.videoViews[i].thumbnailImageView.image = image
                            self.videoViews[i].thumbnailImageView.contentMode = .scaleAspectFill
                    }
                }
                self.videoViews[i].video = videosData[dataIndex]
                self.videoViews[i].notificationLabel.isHidden = true
                if videosData[dataIndex].isActive {
                    self.videoViews[i].notificationLabel.isHidden = false
                    self.videoViews[i].notificationLabel.text = "В кастинге"
                }
                if !(videosData[dataIndex].isApproved ?? false) {
                    self.videoViews[i].notificationLabel.isHidden = false
                    self.videoViews[i].notificationLabel.text = "На модерации"
                }
            }
            
        }
    }
    
}

//MARK:- Configurations
private extension ProfileViewController {
    private func configureViews() {

        //MARK:- • General
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        editImageButton.layer.cornerRadius = editImageButton.frame.width / 2
        descriptionTextView.borderWidthV = 0
        descriptionTextView.borderColorV = UIColor.white.withAlphaComponent(0.7)
        descriptionTextView.isHidden = true
        descriptionTextView.delegate = self
        
        videosContainer.isHidden = true
        videosHeader.isHidden = true
        addNewVideoButton.configureHighlightedColors(color: .darkGray, alpha: 0.8)
        
        //MARK:- • For Public Profile
        if isPublic {
            optionsButton.isEnabled = false
            optionsButton.tintColor = .clear
            
            likesNumberLabel.isHidden = true
            likesDescriptionLabel.isHidden = true
            

            NSLayoutConstraint.activate([
                descriptionHeader.topAnchor.constraint(equalTo: likesNumberLabel.topAnchor)
            ])
        //MARK:- • For Private Profile
        } else {
            videoViews[0].isHidden = true
            addNewVideoButton.isHidden = false
            navigationItem.title = "Мой профиль"
            
            optionsButton.isEnabled = true
            optionsButton.tintColor = .white
        }
        
    }
    
    private func updateViewsData(newData: UserProfile) {
        self.userData = newData
        self.nameLabel.text = newData.name
        if let likes = newData.likesNumber {
            self.likesNumberLabel.text = "\(likes) лайков"
        }
        if let description = newData.description {
            self.descriptionTextView.text = description
            self.descriptionTextView.isHidden = false
            self.descriptionPlaceholder.isHidden = true
        } else {
            self.descriptionTextView.text = ""
        }
    }
    
    //MARK:- Count Non-Hidden Video Views
    private func nonHiddenVideoViews() -> Int {
        var res = 0
        for videoView in videoViews {
            if !videoView.isHidden {
                res += 1
            }
        }
        return res
    }
    
    
    //MARK:- Show Options Alert
    private func showOptionsAlert(editHandler: ((UIAlertAction) -> Void)?, settingsHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        
        let editProfileButton = UIAlertAction(title: "Редактировать профиль", style: .default, handler: editHandler)
        let settingsButton = UIAlertAction(title: "Открыть настройки", style: .default, handler: settingsHandler)
        let cnclBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(editProfileButton)
        alert.addAction(settingsButton)
        alert.addAction(cnclBtn)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Enable Edit Mode
    private func enableEditMode(){
        let cancelEditButton = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        cancelEditButton.tintColor = .white
        self.navigationItem.setLeftBarButton(cancelEditButton, animated: true)
        navigationItem.title = "Ред. профиля"
        
        optionsButton.image = nil
        optionsButton.title = "Сохранить"

        self.editImageButton.isHidden = false
        self.descriptionTextView.borderWidthV = 1.0
        self.descriptionTextView.backgroundColor = .systemFill
        self.descriptionTextView.isEditable = true
        self.descriptionTextView.isSelectable = true
        symbolCounter.isHidden = false
        symbolCounter.text = "\(descriptionTextView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.text = "Расскажи о себе"
        self.isEditMode = true
    }
    
    //MARK:- Disable Edit Mode
    private func disableEditMode() {
        self.navigationItem.setLeftBarButton(nil, animated: true)
        optionsButton.image = UIImage(systemName: "ellipsis.circle.fill")
        optionsButton.title = ""
        navigationItem.title = isPublic ? "Профиль" : "Мой профиль"
        
        self.editImageButton.isHidden = true
        self.descriptionTextView.borderWidthV = 0.0
        self.descriptionTextView.backgroundColor = .systemBackground
        self.descriptionTextView.isEditable = false
        self.descriptionTextView.isSelectable = false
        symbolCounter.isHidden = true
        descriptionPlaceholder.text = "Нет описания"
        descriptionPlaceholder.isHidden = false
        self.isEditMode = false
    }
}


//MARK:- Tab Bar Delegate
extension ProfileViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}


//MARK:- Profile Video View Delegate
extension ProfileViewController: ProfileVideoViewDelegate {
    func playButtonPressed(at index: Int, video: Video) {
        let fullScreenPlayer = AVPlayer(url: video.url!)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        fullScreenPlayerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 100))
        fullScreenPlayerVC.player?.isMuted = true
        fullScreenPlayerVC.player?.play()
        
        present(fullScreenPlayerVC, animated: true, completion: nil)
    }
        
    func optionsButtonPressed(at index: Int, video: Video) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        
        //MARK:- Set Video Active
        let setActiveButton = UIAlertAction(title: "Отправить в кастинг", style: .default) { (action) in
            //set active method
            if !(video.isApproved ?? false) {
                self.showIncorrectUserInputAlert(title: "Видео пока нельзя отправить в кастинг",
                                            message: "Оно ещё не прошло модерацию.")
            } else {
                print("Setting Active video named: '\(video.name)'")
                for videoView in self.videoViews {
                    videoView.notificationLabel.isHidden = true
                }
                self.videoViews[index].notificationLabel.isHidden = false
                
                //MARK:- Set Active Request
                WebVideo.setActive(videoName: video.name) { (serverResult) in
                    switch serverResult {
                    case .error(let error):
                        print("Error: \(error)")
                        self.showErrorConnectingToServerAlert(title: "Не удалось связаться с сервером", message: "Обновите экран профиля и попробуйте еще раз.")
                    case .results(let responseCode):
                        if responseCode != 200 {
                            self.showErrorConnectingToServerAlert(title: "Не удалось связаться с сервером", message: "Обновите экран профиля и попробуйте еще раз.")
                        }
                    }
                }
            }
        }
        
        //MARK:- Delete Video from Profile
        let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
            //delete method

            if video.isActive {
                self.videoViews[index].notificationLabel.isHidden = true
            }
            let leftViewsNumber = self.nonHiddenVideoViews()
            
            if leftViewsNumber == 4 {
                self.addNewVideoButton.isHidden = false
                self.videoViews.first?.isHidden = true
                //rearrangeViews()
                var i = index
                while i > 0 {
                    self.videoViews[i].thumbnailImageView.image = self.videoViews[i-1].thumbnailImageView.image
                    self.videoViews[i].video = self.videoViews[i-1].video
                    self.videoViews[i].notificationLabel.isHidden = !self.videoViews[i-1].video.isActive
                    if let isApproved = self.videoViews[i-1].video.isApproved {
                        if !isApproved {
                            self.videoViews[i].notificationLabel.isHidden = false
                            self.videoViews[i].notificationLabel.text = "На модерации"
                        }
                    }
                    i -= 1
                }
            } else {
                for i in index..<4 {
                    if i < leftViewsNumber {
                        self.videoViews[i].thumbnailImageView.image = self.videoViews[i+1].thumbnailImageView.image
                        self.videoViews[i].video = self.videoViews[i+1].video
                    } else {
                        self.videoViews[i].thumbnailImageView.image = nil
                        self.videoViews[i].isHidden = true
                    }
                }
            }
            print("Number of videos left: \(leftViewsNumber)")
            //print("Video Views: \(self.videoViews)")
            
            //MARK:- Delete Requset
            WebVideo.delete(videoName: video.name) { (serverResult) in
                switch serverResult {
                case .error(let error):
                    print("Error: \(error)")
                    self.showErrorConnectingToServerAlert(title: "Не удалось удалить видео в данный момент", message: "Обновите экран профиля и попробуйте снова.")
                case .results(let responseCode):
                    if responseCode != 200 {
                        self.showErrorConnectingToServerAlert(title: "Не удалось удалить видео в данный момент", message: "Обновите экран профиля и попробуйте снова.")
                    }
                }
            }
        }
        
        let cnclBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(setActiveButton)
        alert.addAction(deleteButton)
        alert.addAction(cnclBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
}


//MARK:- Image Picker Delegate
extension ProfileViewController: UINavigationControllerDelegate {}
extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeImage as String),
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        else { return }
        
        dismiss(animated: true) {
            self.cachedProfileImage = self.profileImageView.image
            self.profileImageView.image = image
        }
        
    }
}


//MARK:- Text View Delegate
extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //can change here e.g. border color
    }
    
    func textViewDidChange(_ textView: UITextView) {
        symbolCounter.text = "\(textView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.isHidden = textView.text.count != 0
        if textView.text.count > symbolLimit {
            textView.borderColorV = .systemRed
            symbolCounter.textColor = .systemRed
        } else {
            textView.borderColorV = UIColor.white.withAlphaComponent(0.7)
            symbolCounter.textColor = .placeholderText
        }
    }

}
