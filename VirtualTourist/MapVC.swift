//
//  MapVC.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/19/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [PinAnnotation]()
    var longPressGesture: UILongPressGestureRecognizer? = nil
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up gestures and add
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        addLongPressGesture()
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        
        self.mapView.delegate = self
        
        if gestureRecognizer.state == .ended {
        
            let pinAnnotation = PinAnnotation()
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            self.latitude = newCoordinates.latitude
            self.longitude = newCoordinates.longitude
            pinAnnotation.setCoordinate(newCoordinate: newCoordinates)
            pinAnnotation.title = "Photo Album"
            
            mapView.addAnnotation(pinAnnotation)
            annotations.append(pinAnnotation)
        }
    }
    
    func addLongPressGesture() {
        self.longPressGesture?.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(self.longPressGesture!)
    }
  
    
    // MARK: Map View
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        if annotation is PinAnnotation {
        
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.pinTintColor = .red
                pinView!.frame.size.height = 30
                
                let arrowButton = UIButton(type: .custom)
                arrowButton.frame.size.width = 25
                arrowButton.frame.size.height = 25
                arrowButton.setImage(UIImage(named: "icons8-Forward Filled-50"), for: .normal)
                arrowButton.addTarget(self, action: #selector(didClickPhotoAlbum), for: .touchUpInside)
                pinView!.rightCalloutAccessoryView = arrowButton
            
                let deleteButton = UIButton(type: .custom)
                deleteButton.backgroundColor = UIColor.red
                deleteButton.frame.size.width = 50
                deleteButton.frame.size.height = 50
                deleteButton.setImage(UIImage(named: "Trash"), for: .normal)
                pinView!.leftCalloutAccessoryView = deleteButton
            
            } else {
                pinView!.annotation = annotation
            }
        
            return pinView
            
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PinAnnotation {
            mapView.removeAnnotation(annotation)
        }
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Notice that this code works for both Scissors and Paper
        if segue.identifier == "photoAlbumVC" {
            let controller = segue.destination as! PhotoAlbumVC
            
            controller.latitude = self.latitude!
            controller.longitude = self.longitude!
            
        }
        
    }
    
    func didClickPhotoAlbum(button: UIButton) {
        
        performSegue(withIdentifier: "photoAlbumVC", sender: self)
        
    }
    
}

class PinAnnotation : NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    var title: String?
    var subtitle: String?
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}

