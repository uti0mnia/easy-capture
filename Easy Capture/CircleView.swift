//
//  CircleView.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-12-24.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    public var fillColour = UIColor.flatRed.cgColor {
        didSet {
            setNeedsLayout()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }
        
        context.setFillColor(fillColour)
        context.fillEllipse(in: rect)
    }
}
