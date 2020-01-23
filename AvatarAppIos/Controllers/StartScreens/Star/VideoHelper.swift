//
//  VideoHelper.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

public class VideoHelper {
  
    //MARK:- Start Media Browser
    static func startMediaBrowser(delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
    
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.videoMaximumDuration = 30.99
        mediaUI.delegate = delegate
        delegate.present(mediaUI, animated: true, completion: nil)
    }
  
    static func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
  
  static func videoCompositionInstruction(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
    
    let transform = assetTrack.preferredTransform
    let assetInfo = orientationFromTransform(transform)
    
    var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
    if assetInfo.isPortrait {
      scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
      let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
        instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor), at: CMTime.zero)
    } else {
      let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
      var concat = assetTrack.preferredTransform.concatenating(scaleFactor)
        .concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
      if assetInfo.orientation == .down {
        let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        let windowBounds = UIScreen.main.bounds
        let yFix = assetTrack.naturalSize.height + windowBounds.height
        let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
        concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
      }
        instruction.setTransform(concat, at: CMTime.zero)
    }
    
    return instruction
  }
    
    
    //MARK:- Upload VIDEO
    static func uploadMedia(url videoPath: URL?, serverPath: String) {
        if videoPath == nil {
            print("Error taking video path")
            return
        }

        guard let url = URL(string: serverPath) else {
            return
        }
        var request = URLRequest(url: url)
        let boundary = "------------------------your_boundary"

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var movieData: Data?
        do {
            movieData = try Data(contentsOf: videoPath!, options: Data.ReadingOptions.alwaysMapped)
        } catch _ {
            movieData = nil
            print("Error catching video Data")
            return
        }

        var body = Data()
        
        // change file name whatever you want
        let filename = "upload.mov"
        let mimetype = "video/mov"

        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(movieData!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, reponse: URLResponse?, error: Error?) in
            if let `error` = error {
                print(error)
                return
            }
            if let `data` = data {
                print(String(data: data, encoding: String.Encoding.utf8)!)
            }
        }

        task.resume()
    }
}
