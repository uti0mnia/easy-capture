//
//  Fonts.swift
//  DotA2 Assistant
//
//  Created by Casey McLewin on 2017-06-06.
//  Copyright © 2017 self. All rights reserved.
//

import Foundation
import UIKit

class Fonts {
    private init() {}
    
    public static var title: UIFont {
        return UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
    }
    
    public static var subtitle: UIFont {
        return UIFont.systemFont(ofSize: 18)
    }
    
    public static var text: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    public static let zoomText = UIFont.systemFont(ofSize: 11)
    
    public static var toastMessage: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    }
}

extension UIFont {
    public var bold: UIFont {
        return UIFont.boldSystemFont(ofSize: self.pointSize)
    }
}
