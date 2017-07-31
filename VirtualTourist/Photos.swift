//
//  Photos.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

class Photos {
    
    var imageUrls = [URL]()
    static let sharedInstance = Photos()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
}

