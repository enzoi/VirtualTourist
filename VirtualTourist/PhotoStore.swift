//
//  Photos.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

enum PinsResult {
    case success([Pin])
    case failure(Error)
}

class PhotoStore {
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        print("processImageRequest is called")
        
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        print("image: ", image)
        
        return .success(image)
    }
    
    
//    func processPhotosRequest(data: Data?, error: Error?, completion: @escaping (PhotosResult) -> Void) {
//        
//        guard let jsonData = data else {
//            completion(.failure(error!))
//            return
//        }
//        
//        self.persistentContainer.performBackgroundTask {
//            (context) in
//            
//            let result = FlickrClient.getFlickrPhotos(pin: <#Pin#>, fromJSON: jsonData, into: context)
//            
//            do {
//                try context.save()
//            } catch {
//                print("Error saving to Core Data: \(error).")
//                completion(.failure(error))
//                return
//            }
//            
//            switch result {
//            case let .success(photos):
//                let photoIDs = photos.map { return $0.objectID }
//                let viewContext = self.persistentContainer.viewContext
//                let viewContextPhotos = photoIDs.map { return viewContext.object(with: $0) } as! [Photo]
//                completion(.success(viewContextPhotos))
//            case .failure(_):
//                completion(result)
//            }
//        }
//    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        print("fetchImage is called")
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL as! URL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    
    
    func fetchFlickrPhotos(pin: Pin, fromParameters url: URL, completion: @escaping (PhotosResult) -> Void) {
        
        print("fetchFlickrPhotos is called")
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: url)
        
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
            
            // Get managedObjectContext
            let moc = self.persistentContainer.viewContext

            // Get [Photo] Array
            var result = FlickrClient.getFlickrPhotos(pin: pin, fromJSON: data, into: moc)
            print("result: ", result)
            
            if case .success = result {
                do {
                    try moc.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
            
        }
        
        // start the task!
        task.resume()
  
    }
    
    
    // MARK: Fetch All Pins in MapVC
    
    func fetchAllPins(completion: @escaping (PinsResult) -> Void) {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let moc = persistentContainer.viewContext
        print("moc in fetchAllPins: ", moc)
        
        moc.perform {
            do {
                let allPins = try moc.fetch(fetchRequest)
                print("all pins to fetch: ", allPins)
                completion(.success(allPins))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Fetch All Photos in PhotoAlbumVC
    
    func fetchAllPhotos(with pin: Pin, completion: @escaping (PhotosResult) -> Void) {
        
        print("pin.pinID: ", pin.pinID!)
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        // Fetch photos associalted with the specific pin
        let predicate = NSPredicate(format: "\(#keyPath(Photo.pin.pinID)) == %@", pin.pinID!)
        fetchRequest.predicate = predicate
        
        print(fetchRequest)
        
        let moc = persistentContainer.viewContext
        
        moc.perform {
            do {
                let allPhotos = try moc.fetch(fetchRequest)
                print("allPhotos: ", allPhotos)
                
                completion(.success(allPhotos))

            } catch {
                completion(.failure(error))
            }
        }
    }

    
}

