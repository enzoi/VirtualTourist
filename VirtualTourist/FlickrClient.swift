//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/30/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

// MARK: - FlickrClient: NSObject

class FlickrClient : NSObject {
    
    // MARK: Properties
    
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }

    // MARK: Flickr API (Get Image URLs)

    func taskForGettingImageFromFlickrByLocation(_ methodParameters: [String: Any], completionHandlerForGet: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
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
                completionHandlerForGet(nil, error)
            
            } else {
                
                for photoItem in photosArray { // photoItem --> [String: AnyObject]

                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoItem[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoItem)")
                        return
                    }
    
                    let imageURL = URL(string: imageUrlString)
                    
                    // Save Image URLs in Shingleton
                    Photos.sharedInstance.imageUrls.append(imageURL!)
                    completionHandlerForGet(parsedResult, nil)
                }
            }
            
        }
    
        // start the task!
        task.resume()
    
        return task
    }

    // MARK: Flickr API (Get Images from Image URLs)

    func getFlickrImage(_ methodParameters: [String: Any], withPageNumber: Int, completionHandlerForGetImage: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        
        /* Make the request */
        let _ = taskForGettingImageFromFlickrByLocation(methodParameters) { (result, error) in
        
            if error != nil {
                print(error)
            
            } else { // success
                if let result = result {
                    completionHandlerForGetImage(result, nil)
                } else {
                    completionHandlerForGetImage(nil, error)
                }
            }
        }

    }
    
    
    private func flickrURLFromParameters(_ parameters: [String:Any]) -> URL {
        
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
    

    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }


}



