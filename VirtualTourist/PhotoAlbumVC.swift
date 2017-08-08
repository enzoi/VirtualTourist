//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/19/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit


class PhotoAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    var store = PhotoStore()
    let photoDataSource = PhotoDataSource()
    
    var annotation = MKPointAnnotation()
    var latitude: Double?
    var longitude: Double?
    
    // Flickr Parameter
    var methodParameters: [String: Any] =  [
        Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
        Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
        Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
        Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
        Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
        Constants.FlickrParameterKeys.Radius: Constants.FlickrParameterValues.Radius,
        Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage,
        Constants.FlickrParameterKeys.Page: Constants.FlickrParameterValues.Page
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        // Span to zoom(code below created based on the solution from https://stackoverflow.com/questions/39615416/swift-span-zoom)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!), span: span)
        detailMapView.setRegion(region, animated: true)
        
        let pinLocation = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
        self.annotation.coordinate = pinLocation
        detailMapView.addAnnotation(annotation)
        
        flowLayoutSetup()
        
        // Get the coordinate
        methodParameters[Constants.FlickrParameterKeys.Latitude] = self.latitude!
        methodParameters[Constants.FlickrParameterKeys.Longitude] = self.longitude!
        
        // Fetch Flickr Photos
        updateDataSource()
    }
    
    private func updateDataSource() {
        
        let url = flickrURLFromParameters(methodParameters)
        
        self.store.fetchFlickrPhotos(fromParameters: url) { (photosResult) -> Void in
        
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
                print("photos: ", photos)
            case let .failure(error):
                print(error)
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayoutSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }

    func flowLayoutSetup() {
        
        let space:CGFloat = 3.0
        var dimension:CGFloat
        
        if view.frame.size.height > view.frame.size.width { // portrait mode
            dimension = (view.frame.size.width - (2 * space)) / 3.0
        } else { // landscape mode
            dimension = (view.frame.size.width - (4 * space)) / 5.0
        }
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }

    
    // MARK:- UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
        cell.imageView.image = nil // Reset image
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.center = CGPoint(x: cell.contentView.frame.size.width / 2, y: cell.contentView.frame.size.height / 2)
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        cell.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        // TODO: Replace existing photo with new one when selected
        // Get another photos from the results

        let randomPhotoIndex = Int(arc4random_uniform(UInt32(self.photoDataSource.photos.count))) // Page Number?
        
        DispatchQueue.global(qos: .background).async {
            let imageURL = self.photoDataSource.photos[randomPhotoIndex].remoteURL
            let data = try? Data(contentsOf: imageURL)
            let image = UIImage(data: data!)!
            
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                cell.imageView?.image = image
            }
        }
        
    }
    
    func flickrURLFromParameters(_ parameters: [String:Any]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        let queryMethod = URLQueryItem(name: Constants.FlickrParameterKeys.Method, value: Constants.FlickrParameterValues.SearchMethod)
        components.queryItems!.append(queryMethod)
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

}


class PhotoViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
}

