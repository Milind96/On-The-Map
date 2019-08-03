//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by milind shelat on 25/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearTextFields()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    let AddLocationID = "AddLocation"
    var lat: Double = 0.0
    var long: Double = 0.0
    var nickname:String = ""
    
    @IBAction func findLocationButtonWasPressed(_ sender: Any) {
    
        if (locationTextField.text?.isEmpty)! || (linkTextField.text?.isEmpty)! {
            present(Alerts.alert(title: "Error", message: "Please Enter a Location and a URL."), animated: true)
        }
        else if !(linkTextField.text?.isValidURL)!{
            present(Alerts.alert(title: "Error", message: "Please Enter a Valid URL!"), animated: true)
        }
        else {
            getuserData()
            getCoordinate(location: locationTextField.text!, completionHandler: handleGetCoordinate(response:error:))
        }
        
    }
    
    @IBAction func cancelButtonWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension InformationPostingViewController : CLLocationManagerDelegate {
    
    func getCoordinate(location : String, completionHandler: @escaping(CLLocationCoordinate2D, Error?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error)
        }
    }
    
    func handleGetCoordinate(response: CLLocationCoordinate2D, error: Error? ) -> Void{
        if response.latitude == -180 || response.longitude == -180{
            present(Alerts.alert(title: "Invalid Location", message: "Please Enter a Valid Location"), animated: true)
        } else {
            long = response.longitude
            lat = response.latitude
            performSegue(withIdentifier: AddLocationID, sender: nil)
        }
    }
    
    func getuserData(){
        OTMClient.getUserData(completion: handleGetUserData(usertDataResponse:errror:))
    }
    func handleGetUserData(usertDataResponse: UserDataResponse?,errror:Error?){
        if let userDataResponse = usertDataResponse {
            nickname = userDataResponse.nickname
        } else {
            present(Alerts.alert(title: "Error", message: "Could not get first and last name"), animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? AddLocationViewController else {
            print("Unable to cast ViewController")
            return
        }
        destinationVC.newLongitude = long
        destinationVC.newLatitude = lat
        destinationVC.mediaURL = linkTextField.text ?? ""
        destinationVC.mapString = locationTextField.text ?? ""
        destinationVC.nickname = nickname
    }
    
}
extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            
            return false
        }
    }

}

extension InformationPostingViewController : UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications() {
        // Subscribing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func unsubscribeFromKeyboardNotifications() {
        // Unsubscribing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if linkTextField.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)/5
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        // Function to get keyboard height
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func clearTextFields(){
        locationTextField.text = ""
        linkTextField.text = ""
    }
    
}
