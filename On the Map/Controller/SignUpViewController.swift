//
//  SignUpViewController.swift
//  On the Map
//
//  Created by milind shelat on 25/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import UIKit
import WebKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://auth.udacity.com/sign-up")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
}

