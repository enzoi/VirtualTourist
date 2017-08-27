//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/19/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var barButton: UIBarButtonItem!

    var store: PhotoStore!
    var imageStore: ImageStore!
    var moc: NSManagedObjectContext!
    var pin: Pin!

    var selectedIndexPaths = [IndexPath]()
    let photoDataSource = PhotoDataSource()

    var fetchedResultsController: NSFetchedResultsController<Photo>?
    var annotation = MKPointAnnotation()

    
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
        
        barButton.title = "New Collection"
        
        // Span to zoom(code below created based on the solution from https://stackoverflow.com/questions/39615416/swift-span-zoom)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.pin.latitude, longitude: self.pin.longitude), span: span)

        detailMapView.setRegion(region, animated: true)
        
        let pinLocation = CLLocationCoordinate2D(latitude: self.pin!.latitude, longitude: self.pin!.longitude)
        self.annotation.coordinate = pinLocation
        detailMapView.addAnnotation(annotation)
        
        flowLayoutSetup()
        
        // Fetch existing photos
        updatePhotos()

        // Fetch new photos if there is no existing photos
        if photoDataSource.photos.count == 0 {
            guard let lat = self.pin?.latitude,
                let lon = self.pin?.longitude
                else { return }
            
            let url = getURL(lat: lat, lon: lon)
            print("self.pin in PhotoAlbumVC: ", self.pin!)
            
            store!.fetchFlickrPhotos(pin: self.pin!, fromParameters: url) { (photosResult) in
 
                self.updatePhotos()
            }
        }
    }
    
    // Helper: Get an URL using given coordinate from MapVC
    
    private func getURL(lat: Double, lon: Double) -> URL {
        // Get the coordinate to create URL
        methodParameters[Constants.FlickrParameterKeys.Latitude] = self.pin?.latitude
        methodParameters[Constants.FlickrParameterKeys.Longitude] = self.pin?.longitude
        
        let url = flickrURLFromParameters(methodParameters)
        
        return url
    }
    
    // MARK: Fetch photos
    
    private func updatePhotos() {
        
        store.fetchAllPhotos(with: self.pin) { (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                
                print("fetched photos: ", photos)
                // Feed pin associated photos to collection view data source
                self.photoDataSource.photos = photos
                
            case .failure(_):
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
        
        DispatchQueue.main.async() {
            let space:CGFloat = 3.0
            var dimension:CGFloat
            
            if self.view.frame.size.height > self.view.frame.size.width { // portrait mode
                dimension = (self.view.frame.size.width - (2 * space)) / 3.0
            } else { // landscape mode
                dimension = (self.view.frame.size.width - (4 * space)) / 5.0
            }
            
            self.flowLayout.minimumInteritemSpacing = space
            self.flowLayout.minimumLineSpacing = space
            self.flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
        
    }

    
    // MARK:- UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        // Download the image data, which could take some time
        store.fetchImage(for: photo, completion: { (result) -> Void in
            
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // When the request finishes, only update the cell if it's still visible
            if let cell = self.collectionView.cellForItem(at: photoIndexPath)
                as? PhotoViewCell {
                cell.update(with: image)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        barButton.title = "Remove Selected Pictures"
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
        cell.alpha = 0.3
        
        selectedIndexPaths.append(indexPath)
        
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

    // MARK: Bar Button
    
    @IBAction func barButtonPressed(_ sender: Any) {
    
        if barButton.title == "New Collection" {
            
            // TODO: Fetch New Collection (Different Page?)
            
        } else { // barButton.title == "Remove Selected Pictures"
            
            // Remove the photo from photo data source
            for indexPath in selectedIndexPaths {
                
                let photo = photoDataSource.photos[indexPath.row]
                if let index = photoDataSource.photos.index(of:photo) {
                    photoDataSource.photos.remove(at: index)
                }
                
                // Remove the photo from core data
                pin.removeFromPhotos(photo)
                
            }

            // Update collection view after removing the photo
            self.collectionView.reloadSections(IndexSet(integer: 0))
            barButton.title = "New Collection"
            selectedIndexPaths = []
        }
    
    }
    
}

// MARK: Core Data

extension PhotoAlbumVC {
    
    func savePhoto(remoteURL: NSURL) {
        
        let moc = store.persistentContainer.viewContext
        print("moc in savePhoto: ", moc)
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Pin.pinID)) == %@", pin.pinID!)
        fetchRequest.predicate = predicate
        
        moc.perform {
            
            // Create a Photo instance
            let photo = Photo(context: moc)
            photo.remoteURL = remoteURL
            // photo.pin = pin
            
            print("created photo: ", photo)
            
            // Get current pin and add the photo to the pin
            let fetchedPin = try? fetchRequest.execute()
            fetchedPin?[0].addToPhotos(photo)
            
            print("saved photo: ", photo)
            
            do {
                try moc.save()
            } catch {
                moc.rollback()
            }
        }
    }

}

