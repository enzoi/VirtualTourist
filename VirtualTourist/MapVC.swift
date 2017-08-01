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
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var annotations = [PinAnnotation]()
    var longPressGesture: UILongPressGestureRecognizer? = nil
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up gestures and add
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        addLongPressGesture()
        
        // Set up activity indicator
        activityIndicator.center = CGPoint(x: mapView.frame.size.width / 2, y: mapView.frame.size.height / 2)
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(Pins.sharedInstance.pins)
        
        // Get all existing pin annotations
        self.activityIndicator.startAnimating()
        
        mapView.removeAnnotations(mapView.annotations)
        
        let pins = Pins.sharedInstance.pins
        
        if pins.count != 0 { // There are pins already
            
            for pin in Pins.sharedInstance.pins {
                    
                let pinAnnotation = pin.getPinAnnotationsFromPin(pin: pin)
                self.annotations.append(pinAnnotation)
                    
            }
                
            performUIUpdatesOnMain {
                // When the array is complete, we add the annotations to the map.
                self.mapView.addAnnotations(self.annotations)
                self.activityIndicator.stopAnimating()
            }
        }
        
        self.activityIndicator.stopAnimating()
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        
        self.mapView.delegate = self
        
        if gestureRecognizer.state == .ended {
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            self.latitude = newCoordinates.latitude
            self.longitude = newCoordinates.longitude
            
            // Save pin
            let pin = Pin(dictionary: ["latitude": newCoordinates.latitude, "longitude": newCoordinates.longitude])
            Pins.sharedInstance.pins.append(pin)
            print("Added", Pins.sharedInstance.pins)
            
            // Get pin annotation
            let pinAnnotation = PinAnnotation()
            pinAnnotation.setCoordinate(newCoordinate: newCoordinates)
            pinAnnotation.id = pin.id
            pinAnnotation.title = "Photo Album"
            
            // Add it to Map View
            mapView.addAnnotation(pinAnnotation)
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
                pinView!.isDraggable = true
                pinView!.pinTintColor = .red
                pinView!.frame.size.height = 30
                
                // Button to lead to the photo album
                let arrowButton = UIButton(type: .custom)
                arrowButton.frame.size.width = 25
                arrowButton.frame.size.height = 25
                arrowButton.setImage(UIImage(named: "icons8-Forward Filled-50"), for: .normal)
                arrowButton.addTarget(self, action: #selector(didClickPhotoAlbum), for: .touchUpInside)
                pinView!.rightCalloutAccessoryView = arrowButton
                
                // Button to delete the pin annotation
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
        
        if control == view.leftCalloutAccessoryView  { // Left Button Tapped
            
            if let annotation = view.annotation as? PinAnnotation {
                Pins.sharedInstance.pins = Pins.sharedInstance.pins.filter { $0.id != annotation.id }
                self.annotations = self.annotations.filter { $0.id != annotation.id }
                print("Deleted? ", annotation.id, Pins.sharedInstance.pins)
                mapView.removeAnnotation(annotation)
            }
            
        } else { // Right Button Tapped
            
            performSegue(withIdentifier: "photoAlbumVC", sender: self)
        
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
        
        
        
    }
    
}

// MARK: Custom Pin Annotation

class PinAnnotation : NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var pinAnnotations = [PinAnnotation]()
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    var id: String?
    var title: String?
    var subtitle: String?
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    
}

