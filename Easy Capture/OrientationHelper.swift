//
//  OrientationHelper.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-12-25.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import Foundation
import UIKit

class OrientationHelper: NSObject {
    
    public static let shared = OrientationHelper()
    
    private override init() {}
    
    public var imageOrientation: UIImageOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .up
        case .landscapeLeft:
            return .left
        case .landscapeRight:
            return .right
        default:
            return .up
        }
    }
    
    
    public func getAssetWriterAffineTransform() -> CGAffineTransform {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return CGAffineTransform.init(rotationAngle: -CGFloat.pi / 2)
        case .landscapeRight:
            return CGAffineTransform.init(rotationAngle: CGFloat.pi / 2)
        default:
            return CGAffineTransform.identity
        }
    }
    
}
