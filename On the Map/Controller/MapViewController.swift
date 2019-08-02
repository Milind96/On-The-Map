//
//  MapViewController.swift
//  On the Map
//
//  Created by milind shelat on 25/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        OTMClient.getStudentLocation(completion:handleGeHundredStudentInfo(studentInfo:error:))
        
    }

    @IBAction func updateLocationWasPressed(_ sender: Any) {
        
        OTMClient.updateStudentLocation(completion: handleGeHundredStudentInfo(studentInfo:error:))
    }
    
    @IBAction func logoutButtonWasPressed(_ sender: Any) {
        
        OTMClient.logout {
            DispatchQueue.main.async {
                OTMClient.Auth.sessionId = ""
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func handleGeHundredStudentInfo(studentInfo:[StudentInformation]?, error:Error?) {
        guard let studentInfo = studentInfo else {
            present(Alerts.alert(title: "Unable to Load", message: error?.localizedDescription ?? ""), animated: true,completion: nil)
            print(error!)
            return
        }
        addAnnotationsToMap(locations: studentInfo)
    }
    
    func addAnnotationsToMap(locations: [StudentInformation?]){
        
        StudentLocationInformation.sharedGlobal.location = locations
        var annotations = [MKPointAnnotation]()
        for dictionary in locations {
            let annotation = MKPointAnnotation()
            guard let lat = dictionary?.latitude, let long = dictionary?.longitude  else {
                continue
            }
            let latitude = CLLocationDegrees(lat)
            let longitude = CLLocationDegrees(long)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinate
            
            if let first = dictionary?.firstName, let last  = dictionary?.lastName {
                annotation.title = "\(first) \(last)"
            }
            
            if let mediaURL = dictionary?.mediaURL{
                annotation.subtitle = mediaURL
            }
            annotations.append(annotation)
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(annotations)
        }
    }
    
}




extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                guard !toOpen.isEmpty else {
                    present(Alerts.alert(title: "Error", message: "URL Does not Exist!"), animated: true)
                    return
                }
                app.open(URL(string: toOpen) ?? URL(string: "")!, options: [:], completionHandler: nil)
            }
        }
    }
}


