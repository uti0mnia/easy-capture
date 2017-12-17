//
//  PreviewViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-28.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
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
    
    public func displayError(message: String?) {
        let alert = UIAlertController(title: "Uh Oh",
                                      message: message,
                                      preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(dismiss)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func displayNoPhotoAccess() {
        let alert = UIAlertController(title: "Problem accessing Photos",
                                      message: "You need to give this app permission to access photos in order for it to save.",
                                      preferredStyle: .alert)
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
    
    public func handleSave(completion: @escaping (Bool) -> Void) {
        assertionFailure("Needs to be implemented by subclass")
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
        PermissionManager.shared.photoPermission() { granted in
            guard granted else {
                self.displayNoPhotoAccess()
                return
            }
            
            self.saveButton?.isEnabled = false
            self.showActivityIndicator()
            self.handleSave() { success in
                if success {
                    ToastManager.shared.displayToastMessage("Saved ✔️")
                } else {
                    self.displayError(message: "Could not save, please try again.")
                }
            }
        }
    }
}






































