//
//  UIView+Shadow.swift
//  DotA2 Assistant
//
//  Created by Casey McLewin on 2017-07-16.
//  Copyright © 2017 self. All rights reserved.
//

import UIKit

extension UIView {
    
    public func u0_addWhiteTextShadow() {
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    public func u0_addToastShadow() {
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
