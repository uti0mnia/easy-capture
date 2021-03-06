//
//  CameraOptionsView.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-11-19.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit
import SnapKit
import ChameleonFramework

protocol CameraStatusBarViewDelegate: class {
    func cameraOptionsViewDidSelectCamera(_ cameraOptionsView: CameraStatusBarView)
    func cameraOptionsViewDidSelectVideo(_ cameraOptionsView: CameraStatusBarView)
    func cameraOptionsViewDidSelectToggleFlash(_ cameraOptionsView: CameraStatusBarView)
    func cameraOptionsViewDidSelectToggleCamera(_ cameraOptionsView: CameraStatusBarView)
}

class CameraStatusBarView: UIView {
    
    public weak var delegate: CameraStatusBarViewDelegate?
    
    private var cameraImage: UIImageView!
    private var videoImage: UIImageView!
    private var toggleCameraImage: UIImageView!
    private var flashImage: UIImageView!
    private var recordingView = CircleView()
    
    public var timerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        addSubviews()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(recordingView)
        recordingView.isHidden = true
        
        timerLabel.text = "00:00"
        timerLabel.font = Fonts.subtitle
        timerLabel.textAlignment = .center
        addSubview(timerLabel)
        
        cameraImage = createImageView(with: #imageLiteral(resourceName: "photo"))
        addSubview(cameraImage)
        
        videoImage = createImageView(with: #imageLiteral(resourceName: "video"))
        addSubview(videoImage)
        
        toggleCameraImage = createImageView(with: #imageLiteral(resourceName: "swapCamera"))
        addSubview(toggleCameraImage)
        
        flashImage = createImageView(with: #imageLiteral(resourceName: "flashoff"))
        addSubview(flashImage)
    }
    
    private func createImageView(with image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Colours.unselectedOptionTint
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapIcon(_:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }
    
    private func addConstraints() {
        recordingView.snp.makeConstraints() { make in
            make.height.width.equalTo(Layout.recordingViewSize.height)
            make.top.equalTo(cameraImage)
            make.centerX.equalTo(timerLabel.snp.centerX)
        }
        
        timerLabel.snp.makeConstraints() { make in
            make.left.equalTo(videoImage.snp.right).offset(Layout.padding)
            make.top.equalTo(recordingView.snp.bottom)
            make.bottom.equalToSuperview().inset(Layout.padding)
            make.right.equalTo(flashImage.snp.left).offset(-Layout.padding)
        }
        
        cameraImage.snp.makeConstraints() { make in
            make.height.equalTo(Layout.optionButtonHeight)
            make.left.bottom.equalToSuperview().inset(Layout.padding)
            make.width.equalTo(cameraImage.snp.height)
        }
        
        videoImage.snp.makeConstraints() { make in
            make.height.equalTo(Layout.optionButtonHeight)
            make.left.equalTo(cameraImage.snp.right).offset(Layout.padding)
            make.bottom.equalToSuperview().inset(Layout.padding)
            make.width.equalTo(videoImage.snp.height)
        }
        
        toggleCameraImage.snp.makeConstraints() { make in
            make.height.equalTo(Layout.optionButtonHeight)
            make.right.bottom.equalToSuperview().inset(Layout.padding)
            make.width.equalTo(toggleCameraImage.snp.height)
        }
        
        flashImage.snp.makeConstraints() { make in
            make.height.equalTo(Layout.optionButtonHeight)
            make.right.equalTo(toggleCameraImage.snp.left).offset(-Layout.padding)
            make.bottom.equalToSuperview().inset(Layout.padding)
            make.width.equalTo(flashImage.snp.height)
        }
    }
    
    public func setRecording(on: Bool) {
        recordingView.isHidden = !on
    }
    
    public func setFlash(on: Bool) {
        flashImage.image = on ? #imageLiteral(resourceName: "flashon") : #imageLiteral(resourceName: "flashoff")
    }
    
    public func setPhotoMode() {
        cameraImage.tintColor = Colours.selectedOptionTint
        videoImage.tintColor = Colours.unselectedOptionTint
        timerLabel.isHidden = true
        recordingView.isHidden = true
    }
    
    public func setVideoMode() {
        cameraImage.tintColor = Colours.unselectedOptionTint
        videoImage.tintColor = Colours.selectedOptionTint
        timerLabel.isHidden = false
        recordingView.isHidden = true
    }
    
    @objc private func didTapIcon(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view else {
            return
        }
        if imageView == cameraImage {
            self.delegate?.cameraOptionsViewDidSelectCamera(self)
        } else if imageView == videoImage {
            self.delegate?.cameraOptionsViewDidSelectVideo(self)
        } else if imageView == flashImage {
            self.delegate?.cameraOptionsViewDidSelectToggleFlash(self)
        } else if imageView == toggleCameraImage {
            self.delegate?.cameraOptionsViewDidSelectToggleCamera(self)
        }
    }
    
}


































