//
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import NVActivityIndicatorView
import Amplitude

class ProfileViewController: XceFactorViewController {

    //MARK: - Properties
    var isFirstLoad = true
    var isPublic = false
    var isEditProfileDataMode = false
    var shouldUpdateSection = false
    var shouldUpdateData = false
    var isEditingVideoInterval = false
    var newImagePicked = false
    
//    weak var downloadRequest: DownloadRequest?

    var videosData = [Video]()
    var newVideo = Video()
    var userData = UserProfile()
    var cachedProfileImage: UIImage?
    var activityIndicatorBarItem = UIActivityIndicatorView()
    var loadingIndicatorFullScreen = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .systemPurple, padding: 8.0)
    weak var profileUserInfo: ProfileUserInfoView!

    // MARK: - IBOutlets
    
    @IBOutlet weak var profileCollectionView: ProfileCollectionView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet var optionsButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCustomNavBar()
        loadingIndicatorFullScreen.enableCentered(in: view)
        configureCollectionView()
        // TODO: Разобраться, что за логика под закоменченными методами
//        configureViews()
//        updateViewsData(newData: userData)
//        updateData(isPublic: isPublic)
        configureRefrechControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldUpdateData {
            updateData(isPublic: isPublic)
            shouldUpdateData = false
        } else if isEditingVideoInterval {
            loadingIndicatorFullScreen.stopAnimating()
            isEditingVideoInterval = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.delegate = self
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        downloadRequestXF?.cancel()
    }

    // MARK: - Overrides
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Add Video from Profile":
            let vc = segue.destination as! VideoPickVC
            vc.isProfileInitiated = true
        case "Upload/Edit Video from Profile":
            let vc = segue.destination as! VideoUploadVC
            vc.video = newVideo
            vc.isProfileDirectly = true
            vc.isEditingVideoInterval = self.isEditingVideoInterval
            vc.navigationItem.title = self.isEditingVideoInterval ? "Изм. фрагмента" : "Выбор фрагмента"
        case "Edit Description":
            let vc = segue.destination as! EditDescriptionVC
            vc.descriptionText = profileUserInfo.descriptionTextView.text
            vc.parentVC = self
            
        default:
            break
        }
    }
    
    //MARK:- Options/Save Button Pressed
    @IBAction
    private func rightBarButtonButtonPressed(_ sender: Any) {
        if !isEditProfileDataMode {
            showOptionsAlert(
                //MARK:- Edit Account Button
                editHandler: { (action) in
                    
                    //MARK:- Edit Profile Log
                    Amplitude.instance()?.logEvent("editprofile_button_tapped")
                    
                    self.enableEditMode()
            },
                //MARK:- Settings Button
                settingsHandler: { (action) in
                    self.performSegue(withIdentifier: "Show Settings", sender: nil)
            },
                //MARK:- Exit Account Button
                quitHandler: { (action) in
                    self.confirmActionAlert(title: "Выйти из аккаунта?", message: "Это завершит текущую сессию пользователя") { (action) in
                        Defaults.clearUserData()
                        TokenAuthentication.setNotificationsToken(token: "")
                        self.setApplicationRootVC(storyboardID: "WelcomeScreenNavBar")
                    }
            })
            
        } else {
            //MARK:- is In Editing Mode
            let (errorMessage, descriptionText, nameText) = profileUserInfo.checkEdits()
            
            guard errorMessage == nil else {
                showIncorrectUserInputAlert(title: errorMessage!, message: "")
                return
            }
            
            let image = profileUserInfo.profileImageView.image
            
            //MARK:- Save Changes Log
            Amplitude.instance()?.logEvent("saveprofile_button_tapped")
            
            activityIndicatorBarItem.enableInNavBar(of: self.navigationItem)
            leftBarButton.isEnabled = false
            
            //MARK:- Save Changes
            uploadDescription(description: descriptionText) {
                self.uploadName(name: nameText)
            }
            uploadImage(image: image)
            
        }
    }
    
    //MARK:- Left Bar Button Pressed
    @IBAction
    private func leftBarButtonPressed(_ sender: Any) {
        if isEditProfileDataMode {
            cancelEditing()
        } else {
            //MARK:- INFO PRESSED
            presentInfoViewController(withHeader: navigationItem.title, infoAbout: .profile)
        }
    }
    
    //MARK:- Edit Image Button Pressed
    @IBAction
    private func editImageButtonPressed(_ sender: Any) {
        //MARK:- Edit Image Log
        Amplitude.instance()?.logEvent("editphoto_button_tapped")
        showMediaPickAlert(mediaTypes: [kUTTypeImage], delegate: self, allowsEditing: true)
    }
    
    //MARK:- Configure Refresh Control
    private func configureRefrechControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        profileCollectionView.refreshControl = refreshControl
        
    }
    
    //MARK:- Handle Refresh Control
    @objc
    private func handleRefreshControl() {
        //Refreshing Data
        disableEditMode()
        updateData(isPublic: isPublic)
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            //self.nameLabel.text = self.userData.name
            self.activityIndicatorBarItem.disableInNavBar(of: self.navigationItem, replaceWithButton: self.optionsButton)
            //self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK:- >>> Update Profile Data <<<
    func updateData(isPublic: Bool) {
        shouldUpdateSection = true
        //loadingIndicatorFullScreen.enableCentered(in: view)
        var id: Int? = nil
        if isPublic { id = self.userData.id }
        Profile.getData(id: id) { (serverResult) in
            self.loadingIndicatorFullScreen.stopAnimating()
            //self.profileCollectionView.refreshControl?.endRefreshing()
            
            switch serverResult {
            case .error(let error):
                print(error)
            case .results(let profileData):
                //self.userData = profileData
                print(profileData)
                DispatchQueue.main.async {
                    self.updateViewsData(newData: profileData)
                }
                
                //MARK:- Get Profile Image
                if let profileImageName = profileData.profilePhoto {
                    self.profileUserInfo.profileImageView.setProfileImage(named: profileImageName) { (image) in
                        self.cachedProfileImage = image
                    }
                }

                //MARK:- Configure Videos Info
                guard let videos = profileData.videos else {
                    return
                }
                print(videos)
         
                self.videosData = []
                for video in videos {
                    self.videosData.append(video.translatedToVideoType())
                }
                self.profileUserInfo.videosHeaderLabel.isHidden = false
                
                if self.profileCollectionView.refreshControl!.isRefreshing {
                    self.profileCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                } else {
                    self.profileCollectionView.reloadData()
                }
                self.profileCollectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
}

extension ProfileViewController {

    func configureViews() {

        //MARK:- • General
        leftBarButton.tintColor = .label
        navigationItem.setLeftBarButton(leftBarButton, animated: false)
        optionsButton.image = IconsManager.getIcon(.optionDotsCircleFill)
        
        configureActivityView() {
            self.downloadRequestXF?.cancel()
            self.profileCollectionView.isUserInteractionEnabled = true
        }
        
        profileUserInfo.configureViews(isProfilePublic: self.isPublic)
        profileUserInfo.instagramButton.addInteraction(UIContextMenuInteraction(delegate: self))
        
        //MARK:- • For Public Profile
        if isPublic {
            (optionsButton.isEnabled, leftBarButton.isEnabled) = (false, false)
            (optionsButton.tintColor, leftBarButton.tintColor) = (.clear, .clear)
            
        //MARK:- • For Private Profile
        } else {
            navigationItem.title = "Мой профиль"
            optionsButton.isEnabled = true
            optionsButton.tintColor = .white
            
            //MARK:- Loading Cached Data
            userData.name = Globals.user.name
            userData.description = Globals.user.description
            userData.likesNumber = Globals.user.likesNumber
        }
        
    }
       
    //MARK:- Update Views Data
    func updateViewsData(newData: UserProfile) {
        userData = newData
        userData.id = newData.id
        
        profileUserInfo.configureViews(isProfilePublic: isPublic)
        profileUserInfo.updateViews(with: newData)
        if let img = cachedProfileImage {
            profileUserInfo.profileImageView.image = img
        }
        if !isPublic {
            Globals.user.videosCount = userData.videos?.count ?? 0
        } else {
            profileUserInfo.instagramButton.isHidden = (newData.instagramLogin ?? "") == ""
        }
    }
    
    //MARK:- Ask if User Wants to Cancel Editing
    ///Suitable when one presses some buttons in profile while it is currently in editing mode
    func askUserIfWantsToCancelEditing(doSomethingIfYes: (() -> Void)?) {
        if isEditProfileDataMode {
            confirmActionAlert(title: "Отменить редактирование?", message: "При переходе на следующий экран внесённые изменения не сохранятся", cancelTitle: "Нет") { (actionIfOk) in
                doSomethingIfYes?()
                self.cancelEditing()
            }
        } else {
            doSomethingIfYes?()
        }
    }
    
    func showOptionsAlert(editHandler: ((UIAlertAction) -> Void)?, settingsHandler: ((UIAlertAction) -> Void)?, quitHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        
        let editProfileButton = UIAlertAction(title: "Редактировать профиль", style: .default, handler: editHandler)
        let settingsButton = UIAlertAction(title: "Настройки", style: .default, handler: settingsHandler)
        let exitAccountButton = UIAlertAction(title: "Выйти из аккаунта", style: .destructive, handler: quitHandler)
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(editProfileButton)
        alert.addAction(settingsButton)
        alert.addAction(exitAccountButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    func enableEditMode(){
        leftBarButton.title = "Отмена"
        leftBarButton.tintColor = .white
        leftBarButton.image = nil
        leftBarButton.isEnabled = true
        //self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
        navigationItem.title = "Ред. профиля"
        
        optionsButton.image = IconsManager.getIcon(.checkmarkSeal)
        //optionsButton.title = "Сохранить"
        
        profileUserInfo.setEditMode(enabled: true)

        self.isEditProfileDataMode = true
    }
    
    func disableEditMode() {
        leftBarButton.image = UIImage(systemName: "info.circle")
        leftBarButton.title = ""
        leftBarButton.isEnabled = true
        //self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
        optionsButton.image = IconsManager.getIcon(.optionDotsCircleFill)
        optionsButton.title = ""
        navigationItem.title = isPublic ? "Профиль" : "Мой профиль"
        navigationItem.setRightBarButton(optionsButton, animated: true)
        view.endEditing(true)
        
        profileUserInfo.setEditMode(enabled: false)
        
        self.isEditProfileDataMode = false
    }
    
    func cancelEditing() {
        if !isEditProfileDataMode { return }
        profileUserInfo.descriptionTextView.text = userData.description
        profileUserInfo.profileImageView.image = cachedProfileImage ?? IconsManager.getIcon(.personCircleFill)
        disableEditMode()
    }
    
    func safelyFinishUploadTasks(handler: (() -> Void)?) {
        if let _ = handler {
            handler!()
        } else {
            self.activityIndicatorBarItem.disableInNavBar(of: self.navigationItem, replaceWithButton: self.optionsButton)
            self.disableEditMode()
        }
    }
    
    func uploadDescription(description: String, handler: (() -> Void)? = nil) {
        Profile.setDescription(newDescription: description) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                self.cancelEditing()
            case .results(let responseCode):
                if responseCode != 200 {
                    self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                    self.cancelEditing()
                } else {
                    self.safelyFinishUploadTasks(handler: handler)
                }
            }
            
        }
    }
    
    func uploadName(name: String, handler: (() -> Void)? = nil) {
        guard name != profileUserInfo.nameLabel.text else {
            self.safelyFinishUploadTasks(handler: handler)
            return
        }
        
        Profile.setNewName(newName: name) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое имя", message: "Проверьте подключение к интернету и попробуйте еще раз")
                self.cancelEditing()
            case .results(let responseCode):
                if responseCode != 200 {
                    self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое имя", message: "Проверьте подключение к интернету и попробуйте еще раз")
                    self.cancelEditing()
                } else {
                    self.profileUserInfo.nameLabel.text = name
                    self.safelyFinishUploadTasks(handler: handler)
                }
            }
        }
    }
    
    func uploadImage(image: UIImage?, handler: (() -> Void)? = nil){
        guard newImagePicked else { return }
        
        Profile.setNewImage(image: image) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert(title: "Не удалось загрузить фото", message: "Обновите экран профиля и попробуйте еще раз")
                self.cancelEditing()
            case .results(let responseCode):
                if responseCode != 200 {
                    self.showErrorConnectingToServerAlert(title: "Не удалось загрузить фото", message: "Обновите экран профиля и попробуйте еще раз")
                    self.cancelEditing()
                } else {
                    self.safelyFinishUploadTasks(handler: handler)
                }
            }
        }
    }
    
    func uploadChanges(name: String, description: String, instagramNickname: String, endEditing: Bool) {
        if endEditing {
            activityIndicatorBarItem.enableInNavBar(of: navigationItem)
            leftBarButton.isEnabled = false
        }
        Profile.updateChanges(name: name, description: description, instagramNickname: instagramNickname) { (sessionResult) in
            
            switch sessionResult {
            case.error(let error):
                print(error)
                self.showErrorConnectingToServerAlert()
            case.results(let isSuccess):
                guard isSuccess else {
                    self.showErrorConnectingToServerAlert()
                    return
                }
                if endEditing {
                    self.disableEditMode()
                    self.updateData(isPublic: self.isPublic)
                }
                self.userData.instagramLogin = instagramNickname
            }
        }
    }
    
    func deleteVideoRequest(videoName: String, handler: (() -> Void)?) {
        loadingIndicatorFullScreen.enableCentered(in: view)
        WebVideo.delete(videoName: videoName) { (isSuccess) in
            self.loadingIndicatorFullScreen.stopAnimating()
            if isSuccess {
                if Globals.user.videosCount == nil {
                    Globals.user.videosCount = 0
                } else {
                    Globals.user.videosCount! -= 1
                }
                handler?()
            } else {
                self.showErrorConnectingToServerAlert(title: "Не удалось удалить видео в данный момент",
                                                      message: "Обновите экран профиля и попробуйте снова.")
            }
        }
    }
 
}

// MARK: - Tab Bar Delegate

extension ProfileViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.profileCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}


//MARK:- Image Picker Delegate
extension ProfileViewController: UINavigationControllerDelegate {}
extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeImage as String),
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            dismiss(animated: true) {
                self.newImagePicked = true
                self.cachedProfileImage = self.profileUserInfo.profileImageView.image
                self.profileUserInfo.profileImageView.image = image
            }
        } else if
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            /*VideoHelper.encodeVideo(at: url) { (encodedUrl, error) in
                guard let resultUrl = encodedUrl else {
                    print("Error:", error ?? "unknown")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) { self.showVideoErrorAlert(with: "Произошла ошибка") }
                    }
                    return
                }*/
                self.newVideo.url = url //resultUrl
                let asset = AVAsset(url: url) //resultUrl
                self.newVideo.length = Double(asset.duration.value) / Double(asset.duration.timescale)
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "Upload/Edit Video from Profile", sender: nil)
                    }
                }
            //}
        }
    }
}
