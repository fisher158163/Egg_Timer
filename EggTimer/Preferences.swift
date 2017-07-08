//
//  Preferences.swift
//  EggTimer
//
//  Created by Liyu on 2017/7/8.
//  Copyright © 2017年 liyu. All rights reserved.
//

import Foundation

struct Preferences {
    var selectedTime: TimeInterval {
        get {
            let savedTime = UserDefaults.standard.double(forKey: "selectedTime")
            if savedTime > 0 {
                return savedTime
            }
            return 360
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedTime")
        
        }
    
    }
    
}
