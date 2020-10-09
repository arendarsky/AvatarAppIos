//
//  VolumeObserver.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import AVFoundation
import MediaPlayer

protocol VolumeObserverDelegate: class {
    func volumeDidChange()
}

class VolumeObserver {
    
    let volumeChangedSystemName = NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    var observer: Any?
    weak var delegate: VolumeObserverDelegate?
    
    init() {
        self.observer = NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(_:)), name: volumeChangedSystemName, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
        self.observer = nil
    }
    
    @objc private func volumeChanged(_ notification: NSNotification) {
        guard
            let info = notification.userInfo,
            let reason = info["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String,
            reason == "ExplicitVolumeChange" else { return }

        delegate?.volumeDidChange()
    }
}
