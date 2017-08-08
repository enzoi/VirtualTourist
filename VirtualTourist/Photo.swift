//
//  Photo.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/27/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

struct Photo {

    let remoteURL: URL
    let photoID: String
    
    init(photoID: String, remoteURL: URL) {
        self.photoID = photoID
        self.remoteURL = remoteURL
    }
}

