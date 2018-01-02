//
//  UIDevice+model.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2018-01-02.
//  Copyright © 2018 Casey McLewin. All rights reserved.
//

import UIKit

// thanks to https://stackoverflow.com/a/11197770/3202778
extension UIDevice {
    public var u0_modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    public var isiPhoneX: Bool {
        return UIDevice.current.u0_modelName == "iPhone10,3" || UIDevice.current.u0_modelName == "iPhone10,6"
    }
}
