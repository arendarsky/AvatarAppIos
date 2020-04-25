//
//  VideoHelper.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

public class VideoHelper {
    
    //MARK:- Start Media Browser
    static func startMediaBrowser(delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, mediaTypes: [CFString], sourceType: UIImagePickerController.SourceType, allowsEditing: Bool = false, modalPresentationStyle: UIModalPresentationStyle = .overFullScreen) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let mediaUI = UIImagePickerController()
        mediaUI.view.backgroundColor = .black
        mediaUI.modalPresentationStyle = modalPresentationStyle
        mediaUI.sourceType = sourceType
        mediaUI.videoQuality = .typeHigh
        mediaUI.videoExportPreset = AVAssetExportPresetPassthrough //AVAssetExportPresetHighestQuality
        mediaUI.mediaTypes = mediaTypes as [String]
        mediaUI.allowsEditing = allowsEditing
        //mediaUI.videoMaximumDuration = 30.99
        mediaUI.delegate = delegate
        delegate.present(mediaUI, animated: true, completion: nil)
    }
    
    
    //MARK:- Compress and encode to .mp4
    static func encodeVideo(at videoURL: URL, completionHandler: ((URL?, Error?) -> Void)?)  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        let startDate = Date()
        
        //Create Export session
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality) else {
            completionHandler?(nil, nil)
            return
        }
        
        //Creating temp path to save the converted video
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("rendered-Video.mp4")
        
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                completionHandler?(nil, error)
            }
        }
        
        exportSession.outputURL = filePath
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession.timeRange = range
        
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "NO ERROR")
                DispatchQueue.main.async {
                    completionHandler?(nil, exportSession.error)
                }
            case .cancelled:
                print("Export canceled")
                DispatchQueue.main.async {
                    completionHandler?(nil, nil)
                }
            //Video conversion finished
            case .completed:
                let endDate = Date()
                let time = endDate.timeIntervalSince(startDate)
                print("Compression time: \(time) seconds")
                print("Successful!")
                print(exportSession.outputURL ?? "NO OUTPUT URL")
                
                DispatchQueue.main.async {
                    completionHandler?(exportSession.outputURL, nil)
                }
                
            default: break
            }
            
        })
    }
    
    
    //MARK:- Create Video Thumbnail from URL
    ///prefer this for local videos
    static func createVideoThumbnail(from videoUrl: URL?, timestamp: CMTime = CMTime(seconds: 0.0, preferredTimescale: 600), completion: @escaping (UIImage?) -> Void) {
        guard let url = videoUrl else {
            print("Url Error")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(UIImage(cgImage: imageRef))
            }
            return

        }
    }
    
    //MARK:- Create Video Thumbnail from Asset
    static func createVideoThumbnail(from videoAsset: AVAsset?, timestamp: CMTime = CMTime(seconds: 0.0, preferredTimescale: 600), completion: @escaping (UIImage?) -> Void) {
        guard let asset = videoAsset else {
            print("invalid asset")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(UIImage(cgImage: imageRef))
            }
            return
        }
        
    }
    
    
    //MARK:- Upload video (OLD)
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


public extension DispatchQueue {
    //❗️must be moved to 'other ext.' file because it's not only about video
    //MARK:- Backgorund Queue extension
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
