//
//  PhotoViewCell.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 8/23/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        update(with: nil)
    }
    
    func update(with image: UIImage?) {
        
        spinner.startAnimating()
        
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            imageView.image = nil
        }
    }
    
}
