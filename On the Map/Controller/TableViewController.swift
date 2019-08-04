//
//  TableViewController.swift
//  On the Map
//
//  Created by milind shelat on 25/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let LocationTableViewID = "LocationTableView"
    var studentInformation = StudentLocationInformation.sharedGlobal.location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OTMClient.getStudentLocation() { locations, error in
            guard locations != nil else {
               self.present(Alerts.alert(title: "Error", message: "Could not get student location"), animated: true)
                self.activityIndicator.stopAnimating()
                return
            }
            //print(locations)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    @IBAction func updateStudentLocationWasPressed(_ sender: Any) {
        OTMClient.updateStudentLocation(completion: handleGeHundredStudentInfo(studentLocation:error:))
    }
    
    func handleGeHundredStudentInfo(studentLocation:[StudentInformation]?, error:Error?) {
        
        guard let studentLocation = studentLocation else {
            present(Alerts.alert(title: "Download Error", message: "Unable to Download Student Locations"), animated: true,completion: nil)
            activityIndicator.stopAnimating()
            print(error!)
            return
        }
        StudentLocationInformation.sharedGlobal.location = studentLocation
        DispatchQueue.main.async {
            // reload table
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func logoutButtonWasPressed(_ sender: Any) {
        
        OTMClient.logout {
            DispatchQueue.main.async {
                OTMClient.Auth.sessionId = ""
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationInformation.sharedGlobal.location.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: LocationTableViewID)
        
        let studentLocation = StudentLocationInformation.sharedGlobal.location[indexPath.row]
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        cell.textLabel?.text = studentLocation!.firstName + " " + studentLocation!.lastName
        cell.detailTextLabel?.text = studentLocation?.mediaURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let toOpen = studentInformation[indexPath.row]?.mediaURL {
            guard !toOpen.isEmpty else {
                present(Alerts.alert(title: "Error", message: "URL does not Exist!"), animated: true)
                return
            }
            app.open(URL(string: studentInformation[indexPath.row]!.mediaURL) ?? URL(string: "")!, options: [:], completionHandler: nil)
        }
    }
}


