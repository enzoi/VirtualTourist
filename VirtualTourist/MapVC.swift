//
//  MapVC.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/19/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let annotation = MKPointAnnotation()
    var longPressGesture: UILongPressGestureRecognizer? = nil
    var tapGesture: UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Edit Button Programmatically
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonPressed(_:)))
        
        // Set up gestures
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeAnnotation))
        
        // Add Long Press Gesture
        addLongPressGesture()

    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        self.annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
    }
    
    func removeAnnotation(gesture: UIGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.ended {
            self.mapView.removeAnnotation(annotation)
        }
        
        resetBarButton(title: "Done")
        
    }
    
    func addTapGesture() {
        self.tapGesture?.numberOfTapsRequired = 1
        self.mapView.addGestureRecognizer(self.tapGesture!)
    }
    
    func addLongPressGesture() {
        self.longPressGesture?.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(self.longPressGesture!)
    }
    
    func resetBarButton(title: String) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(editButtonPressed(_:)))
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {
            
            if let longPressGesture = longPressGesture {
                view.removeGestureRecognizer(longPressGesture)
            }
            
            addTapGesture()
            resetBarButton(title: "Done")
            
        } else {
            
            if let tapGesture = tapGesture {
                view.removeGestureRecognizer(tapGesture)
            }
            
            addLongPressGesture()
            resetBarButton(title: "Edit")
        }
        
    }
}

