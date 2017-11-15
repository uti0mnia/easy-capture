//
//  ToastManager.swift
//  DotA2 Assistant
//
//  Created by Casey McLewin on 2017-07-16.
//  Copyright © 2017 self. All rights reserved.
//

import Foundation
import SwiftMessages

class ToastManager {
    
    private static let defaultDuration: TimeInterval = 2
    
    public static let shared = ToastManager()
    
    private init() {
        SwiftMessages.pauseBetweenMessages = 0.125
    }
    
    public func displayToastMessage(_ message: String, on parentViewController: UIViewController? = nil, tapHandler: (()-> Void)? = nil) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        if parentViewController != nil {
            config.presentationContext = .viewController(parentViewController!)
        } else {
            config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        }
        config.duration = .seconds(seconds: ToastManager.defaultDuration)
        
        let view = ToastView(frame: CGRect(x: 0, y: 0, width: 100, height: Layout.toastMessageHeight))
        view.messageLabel.text = message
        
        let messageView = BaseView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        messageView.installContentView(view, insets: Layout.toastMargin)
        messageView.preferredHeight = view.frame.height + Layout.toastMargin.top + Layout.toastMargin.bottom
        
        if tapHandler != nil {
            messageView.tapHandler = { _ in
                SwiftMessages.hide()
                tapHandler?()
            }
        }
        
        SwiftMessages.hideAll()
        
        SwiftMessages.show(config: config, view: messageView)
    }
}
