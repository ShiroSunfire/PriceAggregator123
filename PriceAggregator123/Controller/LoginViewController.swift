//
//  LoginViewController.swift
//  PriceAggregator
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//


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
        if connection() {
        fbLogin.fbConnect()
        }
    }
    
    @IBAction func twLog(_ sender: Any) {
        if connection() {
        twLogin.twitterConnect()
        }
    }
    
    @IBAction func gmLog(_ sender: Any) {
        if connection() {
        gLogin.gConnect()
        }
    }
    
    func connection()-> Bool{
        if InternetConnection.isConnectedToNetwork() == true {
            print("Internet connection OK")
            return true
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Offline", comment: ""), message: NSLocalizedString("You can't Login now. Please connect to the network", comment: ""), preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.dismiss(animated: true, completion: nil)
                })
            return false
        }
    }
    
    //Mark: - Delegate
    func save(userID: String){
        UserDefaults.standard.set(userID, forKey: "UserID")
        self.dismiss(animated: true, completion: nil)
    }
    
}
