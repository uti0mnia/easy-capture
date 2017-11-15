//
//  CapturePreviewViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-28.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class CapturePreviewViewController: UIViewController {
    
    public let imageView = UIImageView()
    
    private var closeButton: UIButton?
    private var saveButton: UIButton?
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        let x = (self.view.bounds.width - Layout.activityIndicatorSize.width) / 2
        let y = (self.view.bounds.height - Layout.activityIndicatorSize.height) / 2
        view.frame = CGRect(x: x, y: y, width: Layout.activityIndicatorSize.width, height: Layout.activityIndicatorSize.height)
        
        view.hidesWhenStopped = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    private func initViews() {
        imageView.frame = self.view.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(imageView)
        
        let height = Layout.closeButtonSize.height
        let width = Layout.closeButtonSize.width
        let y = self.view.bounds.height - (height + Layout.padding)
        let closeFrame = CGRect(x: Layout.padding, y: y, width: width, height: height)
        
        closeButton = UIButton(frame: closeFrame)
        closeButton?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        closeButton?.addTarget(self, action: #selector(didTapCloseButton(_:)), for: .touchUpInside)
        view.addSubview(closeButton!)
        
        let saveFrame = CGRect(x: self.view.bounds.width - (width + Layout.padding), y: y, width: width, height: height)
        saveButton = UIButton(frame: saveFrame)
        saveButton?.setImage(#imageLiteral(resourceName: "save"), for: .normal)
        saveButton?.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
        view.addSubview(saveButton!)
    }
    
    private func displayNoPhotoAccess() {
        let alert = UIAlertController(title: "Cannot save image", message: "You need to give this app permission to access photos in order for it to save.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        let settings = UIAlertAction(title: "Setting", style: .default) {_ in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        alert.addAction(dismiss)
        alert.addAction(settings)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showActivityIndicator() {
        if activityIndicator.superview == nil {
            view.addSubview(activityIndicator)
        }
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        saveButton?.isEnabled = true
    }
    
    @objc private func didTapCloseButton(_ sender: UIButton) {
        hideActivityIndicator()
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func didTapSaveButton(_ sender: UIButton) {
        guard let image = imageView.image else {
            return
        }
        
        PermissionManager.shared.photoPermission() { granted in
            guard granted else {
                self.displayNoPhotoAccess()
                return
            }
            
            self.saveButton?.isEnabled = false
            self.showActivityIndicator()
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        hideActivityIndicator()
        
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Couldn't save image", message: "Try again", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            return
        }
        
        ToastManager.shared.displayToastMessage("Photo saved ✔️")
        
    }
}





































