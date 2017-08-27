//
//  PhotoDataSource.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 8/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    // private let imageStore = ImageStore()
    
    var managedObjectContext: NSManagedObjectContext?
    var photos: [Photo] = []
    var store = PhotoStore()
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get cell after downloading image data using image urls
        let reuseIdentifier = "photoViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoViewCell
        
        return cell
    }
    
}
