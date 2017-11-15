//
//  Colours.swift
//  DotA2 Assistant
//
//  Created by Casey McLewin on 2017-06-07.
//  Copyright © 2017 self. All rights reserved.
//

import ChameleonFramework

class Colours {
    
    public static var modifierGreen: UIColor {
        return UIColor(hexString: "#297c46")!
    }
    
    public static var modifierRed: UIColor {
        return UIColor(hexString: "#912828")!
    }
    
    public static var defaultTextColour: UIColor {
        return UIColor.flatWhiteDark
    }
    
    public static var secondaryColour: UIColor {
        return UIColor.flatWhite
    }
    
    public static var primaryColour: UIColor {
        return UIColor.flatBlackDark
    }
    
    public static var toastMessage: UIColor {
        return UIColor.flatBlack
    }
    
    public static var toastBackground: UIColor {
        return UIColor.flatWhite
    }
    
    public static var highlightColour: UIColor {
        return UIColor.flatRed
    }
    
    public static var segmentedControlBackground: UIColor {
        return highlightColour
    }
    
    public static var primaryAttributeBorderColour: UIColor {
        return UIColor(hexString: "#daa520")! // Gold
    }
}
