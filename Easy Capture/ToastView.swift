//
//  ToastView.swift
//  DotA2 Assistant
//
//  Created by Casey McLewin on 2017-07-16.
//  Copyright © 2017 self. All rights reserved.
//

import UIKit
import SnapKit

class ToastView: UIView {
    
    public var messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints() { make in
            make.left.top.right.bottom.equalTo(self)
        }
        
        messageLabel.font = Fonts.toastMessage
        messageLabel.textColor = Colours.toastMessage
        messageLabel.textAlignment = .center
        
        backgroundColor = Colours.toastBackground
        
        layer.cornerRadius = Layout.toastCornerRadius
        clipsToBounds = true
        layer.masksToBounds = false
        
        u0_addToastShadow()
    }
    
}
