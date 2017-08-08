//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/30/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

enum FlickrError: Error {
    case invalidJSONData
}

// MARK: - FlickrClient: NSObject

class FlickrClient : NSObject {
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    // MARK: Flickr API (Get Images from Image URLs)

    static func getFlickrPhotos(fromJSON data: Data) -> PhotosResult {
        
        print("getFlickrPhotos function called")
        
        // parse the data
        let parsedResult: [String:AnyObject]!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                // displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return .failure(FlickrError.invalidJSONData)
            }
        
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                // displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return .failure(FlickrError.invalidJSONData)
            }
        
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: Any]] else {
                // displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return .failure(FlickrError.invalidJSONData)
            }
            
            if photosArray.count == 0 {
                return .failure(FlickrError.invalidJSONData)
            }
            
            print("photosArray: ", photosArray)
                
            var finalPhotos = [Photo]()
            for photoItem in photosArray { // photoItem [String: AnyObject]
            
                if let photo = getFlickrPhoto(fromJSON: photoItem) {
                    print("photo: ", photo)
                    finalPhotos.append(photo)
                }
            }
            return .success(finalPhotos)
        
        } catch let error {
            return .failure(error)
        }

    }
    
    private static func getFlickrPhoto(fromJSON json: [String : Any]) -> Photo? {
        guard let url = json["url_m"] else {
            // Don't have enough information to construct a Photo
            return nil
        }
        
        let photoID = UUID().uuidString
        let remoteURL = URL(string: url as! String)!
    
        return Photo(photoID: photoID, remoteURL: remoteURL)
    }

    
}



