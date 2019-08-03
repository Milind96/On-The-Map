//
//  LoginViewController.swift
//  On the Map
//
//  Created by milind shelat on 25/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController{
    
    let WebSignUpId = "WebSignUp"
    let MapViewId = "MapView"
    let CompleteLoginId = "completeLogin"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGesture()
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
    @IBAction func loginButtonwasPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            activityIndicator.stopAnimating()
            self.present(Alerts.alert(title: "Incorrent Credentials", message: "Please enter your username and password"),
                         animated: true, completion: nil)
            return
        }
        activityIndicator.isHidden = false
        loginButton.isEnabled = false
        
        OTMClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: handleLogin(key:sessionId:success:error:))
     }
    
    
    
    func handleLogin(key: Int?, sessionId: String? ,success: Bool,error: Error?){
        setLoggingIn(false)
        guard let _ = key, let _ = sessionId else {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.loginButton.isEnabled = true
                self.present(Alerts.alert(title: "Login Error", message: "Please Enter Valid Credentials"), animated: true, completion: nil)
                return
            }
            return
        }
        
        if success{
            self.performSegue(withIdentifier: self.CompleteLoginId, sender: nil)
        } else {
            present(Alerts.alert(title: "Login Failed", message: error?.localizedDescription ?? ""), animated: true,completion: nil)
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            
            activityIndicator.startAnimating()
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
        DispatchQueue.main.async {
            self.emailTextField.isEnabled = !loggingIn
            self.passwordTextField.isEnabled = !loggingIn
            self.loginButton.isEnabled = !loggingIn
    }
}
    private func configureTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    func showMapVC(){
        let controller = self.storyboard!.instantiateViewController(withIdentifier: MapViewId ) as! UITabBarController
        
        self.present(controller, animated: true, completion: nil)
    }
    
}

extension LoginViewController : UITextFieldDelegate{
    
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
        if passwordTextField.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)/4
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
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
}
