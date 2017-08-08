//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 8/8/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {

}

//var pinID: String
//var latitude: Double
//var longitude: Double
//
//// MARK: Initializers
//
//init(dictionary: [String:Any]) {
//    
//    pinID = UUID().uuidString
//    latitude = dictionary["latitude"] as? Double ?? 0.0
//    longitude = dictionary["longitude"] as? Double ?? 0.0
//}
//
//func getPinAnnotationsFromPin(pin: Pin) -> PinAnnotation {
//    
//    let pinAnnotation = PinAnnotation()
//    pinAnnotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude))
//    pinAnnotation.title = "Photo Album"
//    
//    return pinAnnotation
//}
