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
import MobileCoreServices

class ProfileViewController: UIViewController {

    //MARK:- Properties
    var isPublic = false
    var isEditMode = false
    var videosData = [Video]()
    var userData = User()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var likesDescriptionLabel: UILabel!
    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    
    @IBOutlet weak var addNewVideoButton: UIButton!
    @IBOutlet var videoViews: [ProfileVideoView]!
    
    //MARK:- Profile VC Lifecycle
    ///
    ///
    
    //MARK:- • Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        updateData()
        configureViews()
        self.configureCustomNavBar()
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        configureRefrechControl()
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

    //MARK:- Options Button Pressed
    @IBAction func optionsButtonPressed(_ sender: Any) {
        if isEditMode {
            //save edits
            disableEditMode()
        } else {
            showOptionsAlert(
            editHandler: { (action) in
                self.enableEditMode()
            },
            settingsHandler: { (action) in
                //self.performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
            })
        }
    }
    
    @objc func cancelButtonPressed(_ sender: Any) {
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
        updateData()
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            //self.nameLabel.text = self.userData.name
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK:- Update Profile Data
    func updateData() {
        Profile.getData { (serverResult) in
            switch serverResult {
            case .error(let error):
                print(error)
            case .results(let profileData):
                DispatchQueue.main.async {
                    self.nameLabel.text = profileData.name
                    self.likesNumberLabel.text = "\(profileData.likesNumber!) лайков"
                    if let description = profileData.description {
                        self.descriptionTextView.text = description
                    } else {
                        self.descriptionTextView.text = ""
                    }
                }
                
                //MARK:- Get Profile Image
                if let profileImageName = profileData.profilePhoto {
                    let profileImageLink = "\(domain)/api/profile/photo/get/\(profileImageName)"
                    print("Profile Image Link: \(profileImageLink)")
                    Profile.getProfileImage(name: profileImageName) { (serverResult) in
                        switch serverResult {
                        case .error(let error):
                            print("Error getting profile image: \(error)")
                        case .results(let image):
                            DispatchQueue.main.async {
                                self.profileImageView.image = image
                            }
                        }
                    }
                    //get photo
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
        var start = 1
        if videosData.count == 4 || isPublic {
            self.addNewVideoButton.isHidden = true
            self.videoViews[0].isHidden = false
            start = 0
        }
        
        for i in start..<4 {
            if i > videosData.count {
                self.videoViews[i].isHidden = true
            }
            self.videoViews[i].delegate = self
            self.videoViews[i].isHidden = false
            self.videoViews[i].index = i
            if self.videoViews[i].video.name != videosData[i].name || self.videoViews[i].thumbnailImageView.image == nil {
                VideoHelper.createVideoThumbnailFromUrl(
                    videoUrl: self.videosData[i].url,
                    timestamp: CMTime(seconds: self.videoViews[i].video.startTime, preferredTimescale: 100)) { (image) in
                        self.videoViews[i].thumbnailImageView.image = image
                }
            }
            self.videoViews[i].video = videosData[i]

            if videosData[i].isActive {
                self.videoViews[i].notificationLabel.isHidden = false
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
        descriptionTextView.delegate = self
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
            
            optionsButton.isEnabled = true
            optionsButton.tintColor = .white
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
        
        optionsButton.image = nil
        optionsButton.title = "Сохранить"

        self.editImageButton.isHidden = false
        self.descriptionTextView.borderWidthV = 1.0
        self.descriptionTextView.backgroundColor = .systemFill
        self.descriptionTextView.isEditable = true
        self.descriptionTextView.isSelectable = true
        self.isEditMode = true
    }
    
    //MARK:- Disable Edit Mode
    private func disableEditMode() {
        self.navigationItem.setLeftBarButton(nil, animated: true)
        optionsButton.image = UIImage(systemName: "ellipsis.circle.fill")
        optionsButton.title = ""
        
        self.editImageButton.isHidden = true
        self.descriptionTextView.borderWidthV = 0.0
        self.descriptionTextView.backgroundColor = .systemBackground
        self.descriptionTextView.isEditable = false
        self.descriptionTextView.isSelectable = false
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
            for videoView in self.videoViews {
                videoView.notificationLabel.isHidden = true
            }
            self.videoViews[index].notificationLabel.isHidden = false
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
                self.videoViews.first?.thumbnailImageView.image = nil
                //rearrangeViews()
                var i = index
                while i > 0 {
                    self.videoViews[i].thumbnailImageView.image = self.videoViews[i-1].thumbnailImageView.image
                    self.videoViews[i].video = self.videoViews[i-1].video
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
            self.profileImageView.image = image
            //MARK:- ❗️Update image
        }
        
    }
}


extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}
