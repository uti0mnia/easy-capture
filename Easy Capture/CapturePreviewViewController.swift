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
        let frame = CGRect(x: Layout.padding, y: self.view.bounds.height - (height + Layout.padding), width: width, height: height)
        closeButton = UIButton(frame: frame)
        closeButton?.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        closeButton?.addTarget(self, action: #selector(didTapCloseButton(_:)), for: .touchUpInside)
        view.addSubview(closeButton!)
    }
    
    @objc private func didTapCloseButton(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
}
