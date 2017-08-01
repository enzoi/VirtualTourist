//
//  Pins.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

class Pins {
    
    var pins = [Pin]()
    static let sharedInstance = Pins()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
}
