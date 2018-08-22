//
//  LoginViewController.swift
//  PriceAggregator
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

// google api sign-in 501283990325-b879hgv8qdnci8j23duftjv89h234bps.apps.googleusercontent.com


import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import FacebookLogin
import GoogleSignIn
import GoogleAPIClientForREST
import TwitterKit
import Google

class LoginViewController: UIViewController, FacebookLoginDelegate, GoogleLoginDelegate, TwitterLoginDelegate{
    
  private let fbLogin = FacebookLogin()
  private let twLogin = TwitterLogin()
  private let gLogin = GoogleLogin()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLogin.delegate = self
        gLogin.delegate = self
        twLogin.delegate = self
    }
    
    @IBAction func fbLog(_ sender: Any) {
        fbLogin.fbConnect()
    }
    
    @IBAction func twLog(_ sender: Any) {
        twLogin.twitterConnect()
    }
    
    @IBAction func gmLog(_ sender: Any) {
        gLogin.gConnect()
    }
    
    //Mark: - Delegate
    func save(userID: String){
        UserDefaults.standard.set(userID, forKey: "UserID")
        self.dismiss(animated: true, completion: nil)
    }
    
}
