//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/30/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import CoreData

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

    static func getFlickrPhotos(pin: Pin, fromJSON data: Data, into context: NSManagedObjectContext) -> PhotosResult {
        
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

            var finalPhotos = [Photo]()
            
            for photoItem in photosArray { // photoItem [String: AnyObject]
                
                if let photo = getFlickrPhoto(fromJSON: photoItem, into: context) {
                    
                    //TODO: need to add the fetched photos to the current pin
                    let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
                    let predicate = NSPredicate(format: "\(#keyPath(Pin.pinID)) == %@", pin.pinID!)
                    fetchRequest.predicate = predicate
                        
                    context.perform {
                            
                        // Get current pin and add the photo to the pin
                        let fetchedPin = try? fetchRequest.execute()
                        fetchedPin?[0].addToPhotos(photo)
                    
                        do {
                            try context.save()
                        } catch {
                            context.rollback()
                        }
                    }
                        
                    finalPhotos.append(photo)
                }
            }

            return .success(finalPhotos)
        
        } catch let error {
            return .failure(error)
        }

    }
    
    private static func getFlickrPhoto(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Photo? {

        guard
            let photoID = json["id"] as? String,
            let url = json["url_m"] as? String
        else {
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(photoID)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]?
        
        // Fetch photos to see if there is existing photo available
        context.performAndWait {
            fetchedPhotos = try? fetchRequest.execute()
        }
        
        // Return existing photo if available
        if let existingPhoto = fetchedPhotos?.first {
            return existingPhoto
        }
        
        // Otherwise, create NSManagedObject instance
        var photo: Photo!
        context.performAndWait {
            photo = Photo(context: context)
            photo.remoteURL = NSURL(string: url)
            photo.photoID = photoID
        }

        return photo
    }

    
}



