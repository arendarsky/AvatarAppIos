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

final class ProfileViewController: XceFactorViewController {

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

    // MARK: - Private Properties

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private let profileManager = ProfileServicesManager(networkClient: NetworkClient())

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
    
    // MARK: - IBActions
    /// Заменить IBActions на методы на
    @IBAction
    private func rightBarButtonButtonPressed(_ sender: Any) {
        if !isEditProfileDataMode {
            showOptionsAlert(
                // Edit Account Button
                editHandler: { (action) in
                    
                    //MARK:- Edit Profile Log
                    Amplitude.instance()?.logEvent("editprofile_button_tapped")
                    
                    self.enableEditMode()
            },
                // Settings Button
                settingsHandler: { (action) in
                    self.performSegue(withIdentifier: "Show Settings", sender: nil)
            },
                // Exit Account Button
                quitHandler: { (action) in
                    self.confirmActionAlert(title: "Выйти из аккаунта?", message: "Это завершит текущую сессию пользователя") { (action) in
                        Defaults.clearUserData()
                        TokenAuthentication.setNotificationsToken(token: "")
                        self.setApplicationRootVC(storyboardID: "WelcomeScreenNavBar")
                    }
            })
            
        } else {
            // is In Editing Mode
            let (errorMessage, descriptionText, nameText) = profileUserInfo.checkEdits()
            
            guard errorMessage == nil else {
                showIncorrectUserInputAlert(title: errorMessage!, message: "")
                return
            }
            
            let image = profileUserInfo.profileImageView.image
            
            // Save Changes Log
            Amplitude.instance()?.logEvent("saveprofile_button_tapped")
            
            activityIndicatorBarItem.enableInNavBar(of: self.navigationItem)
            leftBarButton.isEnabled = false
            
            // Save Changes
            uploadDescription(description: descriptionText) {
                self.uploadName(name: nameText)
            }
            uploadImage(image: image)
            
        }
    }
    
    /// Left Bar Button Pressed
    @IBAction
    private func leftBarButtonPressed(_ sender: Any) {
        if isEditProfileDataMode {
            cancelEditing()
        } else {
            // INFO PRESSED
            presentInfoViewController(withHeader: navigationItem.title, infoAbout: .profile)
        }
    }
    
    /// Edit Image Button Pressed
    @IBAction
    private func editImageButtonPressed(_ sender: Any) {
        // Edit Image Log
        Amplitude.instance()?.logEvent("editphoto_button_tapped")
        showMediaPickAlert(mediaTypes: [kUTTypeImage], delegate: self, allowsEditing: true)
    }
    
    // Configure Refresh Control
    private func configureRefrechControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        profileCollectionView.refreshControl = refreshControl
        
    }
    
    @objc private func handleRefreshControl() {
        // Refreshing Data
        disableEditMode()
        updateData(isPublic: isPublic)
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            //self.nameLabel.text = self.userData.name
            self.activityIndicatorBarItem.disableInNavBar(of: self.navigationItem, replaceWithButton: self.optionsButton)
            //self.scrollView.refreshControl?.endRefreshing()
        }
    }

    func updateData(isPublic: Bool) {
        shouldUpdateSection = true
        //loadingIndicatorFullScreen.enableCentered(in: view)
        var id: Int? = nil
        if isPublic { id = userData.id }
        profileManager.getUserData(for: id) { result in
            self.loadingIndicatorFullScreen.stopAnimating()
            //self.profileCollectionView.refreshControl?.endRefreshing()
            
            switch result {
            case .failure(let error):
                print(error)
                // TODO: HANDLE ERROR
            case .success(let profileData):
                //self.userData = profileData
                print(profileData)
                DispatchQueue.main.async {
                    self.updateViewsData(newData: profileData)
                }
                
                // Get Profile Image
                if let profileImageName = profileData.profilePhoto {
                    self.profileUserInfo.profileImageView.setProfileImage(named: profileImageName) { image in
                        self.cachedProfileImage = image
                    }
                }
                
                // Configure Videos Info
                guard let videos = profileData.videos else { return }
                print(videos)
                
                self.videosData = []
                videos.forEach { self.videosData.append($0.translatedToVideoType()) }
                self.profileUserInfo.videosHeaderLabel.isHidden = false
                
                self.profileCollectionView.refreshControl?.isRefreshing ?? false
                    ? self.profileCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
                    : self.profileCollectionView.reloadData()
                
                self.profileCollectionView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension ProfileViewController {

    func configureViews() {

        // General
        leftBarButton.tintColor = .label
        navigationItem.setLeftBarButton(leftBarButton, animated: false)
        optionsButton.image = IconsManager.getIcon(.optionDotsCircleFill)
        
        configureActivityView() {
            self.downloadRequestXF?.cancel()
            self.profileCollectionView.isUserInteractionEnabled = true
        }
        
        profileUserInfo.configureViews(isProfilePublic: self.isPublic)
        profileUserInfo.instagramButton.addInteraction(UIContextMenuInteraction(delegate: self))
        
        // For Public Profile
        if isPublic {
            (optionsButton.isEnabled, leftBarButton.isEnabled) = (false, false)
            (optionsButton.tintColor, leftBarButton.tintColor) = (.clear, .clear)
            
        // For Private Profile
        } else {
            navigationItem.title = "Мой профиль"
            optionsButton.isEnabled = true
            optionsButton.tintColor = .white
            
            // Loading Cached Data
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
        profileManager.set(description: description) { result in
            switch result {
            case .failure(let error):
                // TODO: Routers Refactoring
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                self.cancelEditing()
            case .success:
                 self.safelyFinishUploadTasks(handler: handler)
            }
        }
    }
    
    func uploadName(name: String, handler: (() -> Void)? = nil) {
        guard name != profileUserInfo.nameLabel.text else {
            self.safelyFinishUploadTasks(handler: handler)
            return
        }
        profileManager.set(name: name) { result in
            switch result {
            case .failure:
                // TODO: Replace in AssemblyManager
                self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое имя",
                                                      message: "Проверьте подключение к интернету и попробуйте еще раз")
                self.cancelEditing()
            case .success:
                self.profileUserInfo.nameLabel.text = name
                self.safelyFinishUploadTasks(handler: handler)
            }
        }
    }
    
    func uploadImage(image: UIImage?, handler: (() -> Void)? = nil){
        guard newImagePicked else { return }
        ProfileImage.setNewImage(image: image) { (serverResult) in
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
        // TODO: Разобраться можно ли убрать костыль с endEditing
        if endEditing {
            activityIndicatorBarItem.enableInNavBar(of: navigationItem)
            leftBarButton.isEnabled = false
        }

        let requestModel = ProfileRequestModel(name: name, description: description, instagramLogin: instagramNickname)
        profileManager.updateUserData(requestModel: requestModel) { result in
            switch result {
            case .failure(let error):
                print(error)
                self.showErrorConnectingToServerAlert()
            case .success:
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
                // TODO: In alert Factory
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
