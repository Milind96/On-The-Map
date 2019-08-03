//
//  AddLocationViewController.swift
//  On the Map
//
//  Created by milind shelat on 30/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    var studentLocation : NewLocation?
    
    var newLatitude: Double = 0.0
    var newLongitude: Double = 0.0
    var userLocation: NewLocation?
    var mediaURL: String = ""
    var mapString: String = ""
    var firstName : String = ""
    var lastName : String = ""
    var nickname: String = ""
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapAnnotation()
    }
    
    
    @IBAction func submitButtomWasPressed(_ sender: Any) {
        setUserInfo()
    }
    
    func setUserInfo(){
        let newLocation = NewLocation(uniqueKey: OTMClient.Auth.key, firstName: nickname, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: newLatitude, longitude: newLongitude)
        OTMClient.requestPostStudentInfo(postData: newLocation, completionHandler: handlePostLocationReponse(postLocationResponse:error:))
    }
    
    func setMapAnnotation() {
        
        let lat = CLLocationDegrees(newLatitude)
        let long = CLLocationDegrees(newLongitude)
        let cordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinate
        annotation.title = nickname
        annotation.subtitle = mediaURL
        self.mapView.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 30000, longitudinalMeters: 30000)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func handlePostLocationReponse(postLocationResponse: PostLocationResponse?, error:Error?) {
        guard error != nil else {
            present(Alerts.alert(title: "Error Posting", message: error?.localizedDescription ?? ""), animated: true)
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



extension AddLocationViewController : MKMapViewDelegate{
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
}
