//
//  PhotoDataSource.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 8/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
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
        
        print("photos", self.photos)
        let photo = self.photos[indexPath.row]
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.center = CGPoint(x: cell.contentView.frame.size.width / 2, y: cell.contentView.frame.size.height / 2)
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        cell.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        // Download the image data, which could take some time
        store.fetchImage(for: photo, completion: { (result) -> Void in
            
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    cell.imageView.image = image
                }
            case let .failure(error):
                print(error)
                
            }
        })
        
        return cell
    }
    
}

