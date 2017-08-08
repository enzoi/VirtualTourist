//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 8/8/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var remoteURL: NSObject?
    @NSManaged public var photoID: String?
    @NSManaged public var pin: Pin?

}

//struct Photo {
//    
//    let remoteURL: URL
//    let photoID: String
//    
//    init(photoID: String, remoteURL: URL) {
//        self.photoID = photoID
//        self.remoteURL = remoteURL
//    }
//}
