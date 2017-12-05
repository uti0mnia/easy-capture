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
        cameraImage = UIImageView(image: #imageLiteral(resourceName: "photo").withRenderingMode(.alwaysTemplate))
        cameraImage.tintColor = UIColor.black
        cameraImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapIcon(_:)))
        cameraImage.addGestureRecognizer(tap)
        cameraImage.u0_addBlackImageShadow()
        addSubview(cameraImage)
        
        videoImage = UIImageView(image: #imageLiteral(resourceName: "video").withRenderingMode(.alwaysTemplate))
        videoImage.tintColor = UIColor.black
        videoImage.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapIcon(_:)))
        videoImage.addGestureRecognizer(tap2)
        videoImage.u0_addBlackImageShadow()
        addSubview(videoImage)
        
        toggleCameraImage = UIImageView(image: #imageLiteral(resourceName: "swapCamera").withRenderingMode(.alwaysTemplate))
        toggleCameraImage.tintColor = UIColor.black
        toggleCameraImage.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(didTapIcon(_:)))
        toggleCameraImage.addGestureRecognizer(tap3)
        toggleCameraImage.u0_addBlackImageShadow()
        addSubview(toggleCameraImage)
        
        flashImage = UIImageView(image: #imageLiteral(resourceName: "flashoff").withRenderingMode(.alwaysTemplate))
        flashImage.tintColor = UIColor.black
        flashImage.isUserInteractionEnabled = true
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(didTapIcon(_:)))
        flashImage.addGestureRecognizer(tap4)
        flashImage.u0_addBlackImageShadow()
        addSubview(flashImage)
    }
    
    private func addConstraints() {
        cameraImage.snp.makeConstraints() { make in
            make.left.top.bottom.equalToSuperview()
        }
        
        videoImage.snp.makeConstraints() { make in
            make.left.equalTo(cameraImage.snp.right).offset(Layout.padding)
            make.top.bottom.equalToSuperview()
        }
        
        toggleCameraImage.snp.makeConstraints() { make in
            make.right.top.bottom.equalToSuperview()
        }
        
        flashImage.snp.makeConstraints() { make in
            make.right.equalTo(toggleCameraImage.snp.left).offset(-Layout.padding)
            make.top.bottom.equalToSuperview()
        }
    }
    
    public func setFlash(on: Bool) {
        flashImage.image = on ? #imageLiteral(resourceName: "flashon") : #imageLiteral(resourceName: "flashoff")
    }
    
    public func setCameraMode() {
        cameraImage.tintColor = UIColor.green
        videoImage.tintColor = UIColor.black
    }
    
    public func setVideoMode() {
        cameraImage.tintColor = UIColor.black
        videoImage.tintColor = UIColor.green
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


































