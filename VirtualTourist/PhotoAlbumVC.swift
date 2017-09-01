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
    var pin: Pin!

    var selectedIndexPaths = [IndexPath]()
    let photoDataSource = PhotoDataSource()

    var annotation = MKPointAnnotation()

    
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
        print(photoDataSource.photos.count)
        
        if photoDataSource.photos.count == 0 {
            guard let lat = self.pin?.latitude,
                let lon = self.pin?.longitude
                else { return }
            
            let url = getURL(lat: lat, lon: lon)
            print("url: ", url)
            
            // context?
            store!.fetchFlickrPhotos(pin: self.pin!, fromParameters: url) { (photosResult) in
                
                self.updatePhotos()
            }
        }
    }
    
    // Helper: Get an URL using given coordinate from MapVC
    
    private func getURL(lat: Double, lon: Double) -> URL {
        // Get the coordinate to create URL
        store.methodParameters[Constants.FlickrParameterKeys.Latitude] = self.pin?.latitude
        store.methodParameters[Constants.FlickrParameterKeys.Longitude] = self.pin?.longitude
        
        let url = store.flickrURLFromParameters(store.methodParameters)
        
        return url
    }
    
    // MARK: Fetch photos
    
    private func updatePhotos() {
        
        print("updatePhotos called")
        
        store.fetchAllPhotos(with: self.pin) { (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                
                print("photos: ", photos)
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
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoViewCell
        
        if cell.alpha == 1 { // When a photo is selected
            cell.alpha = 0.3
            selectedIndexPaths.append(indexPath)
            
        } else { // Deselect the photo
            cell.alpha = 1
            print(indexPath)
            if let index = selectedIndexPaths.index(of:indexPath) {
                selectedIndexPaths.remove(at: index)
            }
        }
        
        // Change Bar Button Title
        if selectedIndexPaths.count > 0 {
            barButton.title = "Remove Selected Pictures"
        } else {
            barButton.title = "New Collection"
        }
        
    }
    


    // MARK: Bar Button
    
    @IBAction func barButtonPressed(_ sender: Any) {
        
        if barButton.title == "New Collection" {

            
            // Remove photos from data source, core data
            let moc = self.store.persistentContainer.viewContext
            
            moc.perform {
                
                if let pin = self.pin {
                    pin.removeFromPhotos(pin.photos!)
                }
                
                self.photoDataSource.photos.removeAll()

                do {
                    try moc.save()
                } catch {
                    moc.rollback()
                }
            }
            
            // Get New Collection (Try next page)
            store.methodParameters[Constants.FlickrParameterKeys.Page] = (store.methodParameters[Constants.FlickrParameterKeys.Page] as! Int) + 1
            print(store.methodParameters[Constants.FlickrParameterKeys.Page]!)
            
            let url = store.flickrURLFromParameters(store.methodParameters)
            
            print(url)

            store!.fetchFlickrPhotos(pin: self.pin!, fromParameters: url) { (photosResult) in
                
                self.updatePhotos()
                
            }
            
            
        } else { // barButton.title == "Remove Selected Pictures"
            
            // Remove the photo from photo data source
            for indexPath in selectedIndexPaths {
                
                let photo = photoDataSource.photos[indexPath.row]
                if let index = photoDataSource.photos.index(of:photo) {
                    photoDataSource.photos.remove(at: index)
                }
                
                let moc = self.store.persistentContainer.viewContext
                
                moc.perform {
                    self.pin.removeFromPhotos(photo)
                    
                    do {
                        try moc.save()
                    } catch {
                        moc.rollback()
                    }
                }
            }

            // Update collection view after removing the photo
            self.collectionView.reloadSections(IndexSet(integer: 0))
            barButton.title = "New Collection"
            selectedIndexPaths = []
        }
    
    }
    
}


