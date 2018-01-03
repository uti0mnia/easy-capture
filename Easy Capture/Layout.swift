//
//  Layout.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-28.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class Layout {
    public static let padding: CGFloat = 8
    
    public static let recordButtonSide: CGFloat = 70
    
    public static let closeButtonSize = CGSize.init(width: 50, height: 50)
    
    public static let activityIndicatorSize = CGSize.init(width: 50, height: 50)
    
    public static let toastCornerRadius: CGFloat = 3
    
    public static let toastMargin = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
    
    public static let toastMessageHeight: CGFloat = 60
    
    public static let optionViewHeight: CGFloat = 50
    
    public static let optionButtonHeight: CGFloat = Layout.optionViewHeight - 2 * Layout.padding
    
    public static let recordingViewSize = CGSize(width: 10, height: 10)
    
    public static let zoomViewBorderWidth: CGFloat = 1.5
    
    public static let zoomViewSide: CGFloat = 35
}
