//
//  VideoPreviewViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-12-04.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit
import AVKit

class VideoPreviewViewController: AVPlayerViewController {
    
    public var url: URL? {
        didSet {
            removeObservers()
            if let url = url {
                self.player = AVPlayer(url: url)
                addObservers()
                self.player?.play()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showsPlaybackControls = false
        allowsPictureInPicturePlayback = false
        updatesNowPlayingInfoCenter = false
    }
    
    deinit {
        removeObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: self.player?.currentItem)
    }
    
    @objc private func playerItemDidReachEnd(notification: NSNotification) {
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
    }
}
