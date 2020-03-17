//
//  ProfileViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit

class ProfileViewController: UIViewController {

    //MARK:- Properties
    var isPublic = false
    var videosData = [Video]()
    var profileLink: URL?
    
    @IBOutlet weak var navBarImageView: UIImageView!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarImageView.isHidden = true
        configureViews()
        self.configureCustomNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureRefrechControl()
    }

    //MARK:- Options Button Pressed
    @IBAction func optionsButtonPressed(_ sender: Any) {
        //show alert
    }
    
    //MARK:- Edit Profile Image Button Pressed
    @IBAction func editImageButtonPressed(_ sender: Any) {
        //show img picker
    }
    
    //MARK:- Add New Video Button Pressed
    @IBAction func addNewVideoButtonPressed(_ sender: Any) {
        
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
                self.nameLabel.text = profileData.user.name
                self.likesNumberLabel.text = "\(profileData.likesNumber!) лайков"
                self.descriptionTextView.text = profileData.user.description!
                if let profileImageName = profileData.user.profilePhoto {
                    self.profileLink = URL(string: "\(domain)/api/profile/photo/get/\(profileImageName)")
                    //get photo
                }

                //MARK:- Configure Videos Info
                for video in profileData.user.videos {
                    let newVideo = Video()
                    newVideo.name = video.name
                    newVideo.startTime = video.startTime / 1000
                    newVideo.endTime = video.endTime / 1000
                    newVideo.isActive = video.isActive
                    let url = "\(domain)/api/video/\(video.name)"
                    newVideo.url = URL(string: url)
                    
                    self.videosData.append(newVideo)
                }
                
                self.matchVideosToViews(videosData:self.videosData, isPublic: self.isPublic)
                
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
            self.videoViews[i].video = videosData[i]
            self.videoViews[i].thumbnailView.image = VideoHelper.createVideoThumbnailFromUrl(
                videoUrl: self.videoViews[i].video.url,
                timestamp: CMTime(seconds: self.videoViews[i].video.startTime, preferredTimescale: 100)
            )
            
            if videosData[i].isActive {
                self.videoViews[i].notificationLabel.isHidden = false
            }
            if i > videosData.count {
                self.videoViews[i].isHidden = true
            }
        }
    }
    
}

//MARK:- Configurations
private extension ProfileViewController {
    private func configureViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        descriptionTextView.borderWidthV = 0
        addNewVideoButton.configureHighlightedColors(color: .darkGray, alpha: 0.8)
        
        isPublic = true
        if isPublic {
            optionsButton.isEnabled = false
            optionsButton.tintColor = .clear
            
            likesNumberLabel.isHidden = true
            likesDescriptionLabel.isHidden = true
            

            NSLayoutConstraint.activate([
                descriptionHeader.topAnchor.constraint(equalTo: likesNumberLabel.topAnchor)
            ])
        } else {
            videoViews[0].isHidden = true
            addNewVideoButton.isHidden = false
            
            optionsButton.isEnabled = true
            optionsButton.tintColor = .white
        }
        
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
