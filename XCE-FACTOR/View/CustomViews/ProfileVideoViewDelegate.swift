//
//  ProfileVideoViewDelegate.swift
//  XCE-FACTOR
//
//  Created by Владислав on 05.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

protocol ProfileVideoViewDelegate: class {
    func playButtonPressed(at index: Int, video: Video)
    func optionsButtonPressed(at index: Int, video: Video)
    func copyLinkButtonPressed(at index: Int, video: Video)
    func shareButtonPreseed(at index: Int, video: Video)
    func shareToInstagramStoriesButtonPressed(at index: Int, video: Video)
    
    //func addNewVideoButtonPressed(_ sender: UIButton)
}
