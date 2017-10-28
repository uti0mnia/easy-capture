//
//  PermissionManager.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import Foundation
import AVFoundation

class PermissionManager {
    
    public static let shared  = PermissionManager()
    
    private init() {}
    
    public func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
            return
        }
        
        completion(AVCaptureDevice.authorizationStatus(for: .video) == .authorized)
    }
    
}
