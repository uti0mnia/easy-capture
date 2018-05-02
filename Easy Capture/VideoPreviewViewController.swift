//
//  VideoPreviewViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-12-04.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit
import AVKit
import Photos

class VideoPreviewViewController: PreviewViewController {
    
    public var url: URL? {
        didSet {
            removeObservers()
            if let url = url {
                self.player.replaceCurrentItem(with: AVPlayerItem(url: url))
                self.player.play()
                
                removeObservers()
                addObservers()
            }
        }
    }
    private var player = AVPlayer()
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspect
        view.layer.insertSublayer(playerLayer!, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    deinit {
        removeObservers()
    }
    
    public override func handleSave(completion: @escaping (Bool) -> Void) {
        guard let url = url else {
            return
        }
        
        let currentThreadCompletion: (Bool) -> Void = { success in
            completion(success)
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url.absoluteURL)
        }) { success, error in
            if let error = error {
                print(error.localizedDescription)
                currentThreadCompletion(false)
            } else {
                currentThreadCompletion(true)
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player.currentItem)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
    }
    
    @objc private func playerItemDidReachEnd(notification: NSNotification) {
        self.player.seek(to: kCMTimeZero)
        self.player.play()
    }
}
