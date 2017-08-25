//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 8/8/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject {
    
    func getPinAnnotationsFromPin(pin: Pin) -> PinAnnotation {
        
        let pinAnnotation = PinAnnotation()
        pinAnnotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        pinAnnotation.title = "Photo Album"
        pinAnnotation.id = pin.pinID
        
        print("pin annotation id: ", pinAnnotation.id!)
        
        return pinAnnotation
    }
    
}


