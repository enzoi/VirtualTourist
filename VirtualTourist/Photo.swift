//
//  Photo.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/27/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

struct Photo {

    var id: String?
    var title: String?
    var farm: String?
    var secret: String?
    var server: String?
    var imageURL: URL? {
        get {
            let url = URL(string: "http://farm\(String(describing: farm)).staticflickr.com/\(String(describing: server))/\(String(describing: id))_\(String(describing: secret))_m.jpg")!
            return url
        }
    }
 
    // MARK: Initializers
    
    init(dictionary: [String:Any]) {

        id = dictionary["id"] as? String
        title = dictionary["title"] as? String
        farm = dictionary["farm"] as? String
        secret = dictionary["secret"] as? String
        server = dictionary["server"]as? String

    }
    
    /*
    static func photosFromResults(_ results: [String:AnyObject]) -> [Photo] {
        
        var photos = Photos.sharedInstance.photos
        
        // iterate through array of dictionaries, each Photo is a dictionary
        for result in results {
            photos.append(Photo(dictionary: results))
        }
        
        return photos
    }
    */
}
