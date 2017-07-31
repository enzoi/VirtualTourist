//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/19/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit


class PhotoAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var annotation = MKPointAnnotation()
    var latitude: Double?
    var longitude: Double?
    
    let sampleImageUrls = ["https://farm5.staticflickr.com/4324/36274567625_f4d42d4a3a.jpg", "https://farm5.staticflickr.com/4304/36232782446_585383f981.jpg", "https://farm5.staticflickr.com/4326/36232780226_030bfc5ea5.jpg", "https://farm5.staticflickr.com/4312/36223785186_2ce54ff6f3.jpg", "https://farm5.staticflickr.com/4309/35431097404_cd6d134378.jpg", "https://farm5.staticflickr.com/4299/36097603692_4df2ba68a7.jpg", "https://farm5.staticflickr.com/4313/35431087154_441e911a49.jpg", "https://farm5.staticflickr.com/4307/36214467006_ab0b19e158.jpg", "https://farm5.staticflickr.com/4310/35448063073_d566d7596e.jpg", "https://farm5.staticflickr.com/4317/36118212531_1ee109de73.jpg", "https://farm5.staticflickr.com/4320/35448061673_41f192f9b7.jpg", "https://farm5.staticflickr.com/4317/36118209261_497dacd0e3.jpg", "https://farm5.staticflickr.com/4314/35448060163_34a1f1a724.jpg", "https://farm5.staticflickr.com/4323/36118202771_7d6cf8ea28.jpg", "https://farm5.staticflickr.com/4316/36085445652_e7b5151459.jpg", "https://farm5.staticflickr.com/4326/35448032663_2ab0928a9b.jpg", "https://farm5.staticflickr.com/4318/35859216770_ce5c05da22.jpg", "https://farm5.staticflickr.com/4298/35469883763_932e673b89.jpg", "https://farm5.staticflickr.com/4297/36107537722_d616b1db03.jpg", "https://farm5.staticflickr.com/4311/36107533732_77d1535fda.jpg", "https://farm5.staticflickr.com/4325/36140841561_65e5ed1c1d.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Span to zoom(code below created based on the solution from https://stackoverflow.com/questions/39615416/swift-span-zoom)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!), span: span)
        detailMapView.setRegion(region, animated: true)
        
        let pinLocation = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
        
        self.annotation.coordinate = pinLocation
        detailMapView.addAnnotation(annotation)
        
        // Flickr Parameter
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Latitude: self.latitude!,
            Constants.FlickrParameterKeys.Longitude: self.longitude!,
            Constants.FlickrParameterKeys.PerPage: 21, // 3 X 7 = 21 photos displayed in collection view
            Constants.FlickrParameterKeys.Page: 1
            ] as [String : Any]
        
        // Get image urls from Flickr
        displayImageFromFlickrBySearch(methodParameters as [String:AnyObject])
        
        flowLayoutSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // flowLayoutSetup()
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


    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                // let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                // let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                
                for photoItem in photosArray { // photoItem --> [String: AnyObject]
                
                    print(photoItem)
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoItem[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoItem)")
                        return
                    }
                
                    print(imageUrlString)
                    let imageURL = URL(string: imageUrlString)
                    Photos.sharedInstance.imageUrls.append(imageURL!)

                }
            }
        }
        
        // start the task!
        task.resume()
    }
    
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums
        if let latitude = self.latitude, let longitude = self.longitude {
            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }

    
    // MARK:- UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleImageUrls.count // photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get cell after downloading image data using image urls
        
        let reuseIdentifier = "photoViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoViewCell
        
        let urlString = sampleImageUrls[indexPath.row]
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request) { (data, response, error)  in
            
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                let image = UIImage(data: data!)
                print(image!)
                
                DispatchQueue.main.async {
                    cell.imageView?.image = image
                }
            }
        }
        
        task.resume()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        // TODO: Replace existing photo with new one when selected
        // Get another photos from the results
        
        
    }

}

class CustomImageView: UIImageView {
    
    func loadImageUsingUrl(url: URL) {
        
        
    }
}

class PhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,

                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
