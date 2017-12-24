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
    private var recordingView = UIView()
    
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
        timerLabel.text = "00:00"
        timerLabel.font = Fonts.text
        timerLabel.textAlignment = .center
        timerLabel.u0_addBlackTextShadow()
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
        imageView.u0_addBlackImageShadow()
        return imageView
    }
    
    private func addConstraints() {
        timerLabel.snp.makeConstraints() { make in
            make.left.equalTo(videoImage.snp.right).offset(Layout.padding)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(flashImage.snp.left).offset(-Layout.padding)
        }
        
        cameraImage.snp.makeConstraints() { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(cameraImage.snp.height)
        }
        
        videoImage.snp.makeConstraints() { make in
            make.left.equalTo(cameraImage.snp.right).offset(Layout.padding)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(videoImage.snp.height)
        }
        
        toggleCameraImage.snp.makeConstraints() { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(toggleCameraImage.snp.height)
        }
        
        flashImage.snp.makeConstraints() { make in
            make.right.equalTo(toggleCameraImage.snp.left).offset(-Layout.padding)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(flashImage.snp.height)
        }
        
//        recordingView.snp.makeConstraints() { make in
//            make.centerX.equalTo(self.snp.centerX)
//            make.right.equalTo(timerLabel.snp.left).offset(-Layout.padding)
//        }
    }
    
    public func setFlash(on: Bool) {
        flashImage.image = on ? #imageLiteral(resourceName: "flashon") : #imageLiteral(resourceName: "flashoff")
    }
    
    public func setCameraMode() {
        cameraImage.tintColor = Colours.selectedOptionTint
        videoImage.tintColor = Colours.unselectedOptionTint
    }
    
    public func setVideoMode() {
        cameraImage.tintColor = Colours.unselectedOptionTint
        videoImage.tintColor = Colours.selectedOptionTint
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


































