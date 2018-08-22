//
//  GoogleLogin.swift
//  PriceAggregator123
//
//  Created by student on 8/22/18.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import Google

protocol GoogleLoginDelegate{
    func save(userID: String)
}

class GoogleLogin: NSObject, GIDSignInDelegate, GIDSignInUIDelegate{
   
    var delegate: GoogleLoginDelegate?
    
    override init() {
        super.init()
        let gidSingIn = GIDSignIn()
        gidSingIn.delegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    func gConnect(){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
             self.delegate?.save(userID: user.userID)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("dismissing Google SignIn")
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
         print("presenting Google SignIn")
    }
    
}
