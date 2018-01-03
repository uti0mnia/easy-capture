//
//  ZoomView.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2018-01-02.
//  Copyright © 2018 Casey McLewin. All rights reserved.
//

import UIKit

class ZoomView: UIView {
    
    private(set) var label: UILabel
    
    public var zoom: CGFloat = 1 {
        didSet {
            label.text = String(format: "%.1fx", zoom)
        }
    }
    
    override init(frame: CGRect) {
        label = UILabel()
        
        super.init(frame: frame)
        
        label.textAlignment = .center
        label.text = "1.0x"
        label.textColor = Colours.zoomViewColour
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let side = min(bounds.height, bounds.width)
        frame.size = CGSize(width: side, height: side)
        
        layer.cornerRadius = side/2
        layer.borderColor = Colours.zoomViewColour?.cgColor
        layer.borderWidth = Layout.zoomViewBorderWidth
        
//        let origin = side * (sqrt(2) - 1 / 2)
//        let length = side - origin * 2
    
        label.frame = self.bounds
    }
    
}
