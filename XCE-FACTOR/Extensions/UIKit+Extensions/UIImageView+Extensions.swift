//
//  UIImageView+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension UIImageView {
    //MARK:- Get Profile Image Request
    ///Sets image by the given name or, if the name is nil, sets the default icon for profile.
    ///
    ///Also has a handler returning the received UIImage
    func setProfileImage(named: String?, cache: ((UIImage?) -> Void)? = nil) {
        guard let imageName = named else { return }

        Profile.getProfileImage(name: imageName) { serverResult in
            switch serverResult {
            case .error(let error):
                print(error)
                self.image = IconsManager.getIcon(.personCircleFill)
            case .results(let profileImage):
                self.image = profileImage
                cache?(profileImage)
            }
        }
    }
}
