//
//  TimeHelper.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-12-17.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import Foundation

struct SimpleTimeParts {
    public var seconds: Int = 0 {
        didSet {
            guard seconds >= 0 else {
                seconds = 0
                return
            }
            
            while (seconds / 60 > 0) {
                seconds -= 60
                minutes += 1
            }
        }
    }
    
    public var minutes: Int = 0 {
        didSet {
            guard minutes >= 0 else {
                minutes = 0
                return
            }
            
            while (minutes / 60 > 0) {
                minutes -= 60
                hours += 1
            }
        }
    }
    
    public var hours: Int = 0 {
        didSet {
            if hours < 0 {
                hours = 0
            }
        }
    }
    
    public var shortString: String {
        let args = hours == 0 ? [minutes, seconds] : [hours, minutes]
        return String(format: "%02d:%02d", arguments: args)
    }
    
    public var fullString: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
