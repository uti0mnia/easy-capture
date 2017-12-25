//
//  UserDefaultsHelper.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-12-25.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import Foundation

class UserDefaultsManager: NSObject {
    private static let cameraModeKey = "EasyCapture.CameraModeKey"
    
    public static var shared = UserDefaultsManager()
    
    private override init() {}
    
    public func setLastCameraMode(_ mode: MainViewController.CameraMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: UserDefaultsManager.cameraModeKey)
    }
    
    public func getLastCameraMode() -> MainViewController.CameraMode? {
        // returns 0 if not int value (first time using app - which defaults to camera which is fine)
        return MainViewController.CameraMode(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsManager.cameraModeKey))
    }
    
}
