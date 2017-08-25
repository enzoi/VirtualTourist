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

/*
 
 let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
 activityIndicator.center = CGPoint(x: cell.contentView.frame.size.width / 2, y: cell.contentView.frame.size.height / 2)
 activityIndicator.color = UIColor.lightGray
 activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
 cell.addSubview(activityIndicator)
 
 activityIndicator.startAnimating()
 
 print("photos", self.photos)
 let photo = self.photos[indexPath.row]
 
 // Download the image data, which could take some time
 store.fetchImage(for: photo, completion: { (result) -> Void in
 
 // The index path for the photo might have changed between the
 // time the request started and finished, so find the most
 // recent index path
 
 // (Note: You will have an error on the next line; you will fix it shortly)
 guard let photoIndex = self.photos.index(of: photo),
 case let .success(image) = result else {
 return
 }
 let photoIndexPath = IndexPath(item: photoIndex, section: 0)
 
 
 
 // When the request finishes, only update the cell if it's still visible
 if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoViewCell {
 cell.update(with: image)
 }
 })
*/
