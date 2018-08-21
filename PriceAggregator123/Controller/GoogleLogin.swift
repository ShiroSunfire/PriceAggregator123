////
////  GoogleLogin.swift
////  PriceAggregator123
////
////  Created by student on 8/21/18.
////  Copyright © 2018 student. All rights reserved.
////
//
//import UIKit
//import Google
//import GoogleSignIn
//import GoogleAPIClientForREST
//
//class GoogleLogin: GIDSignInDelegate, GIDSignInUIDelegate{
//    
//    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
//
//    init() {
//        let gidSingIn = GIDSignIn()
//        
//        GIDSignIn.sharedInstance().uiDelegate = self
//        gidSingIn.delegate = self
//        GIDSignIn.sharedInstance().delegate = self
//        
//        var configureError:NSError?
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        
//        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
//    }
//    
// func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
//                withError error: NSError!) {
//        if (error == nil) {
//            // Perform any operations on signed in user here.
//            print(user.userID)                // For client-side use only!
//            print(user.authentication.idToken) // Safe to send to the server
//            print(user.profile.name)
//            print(user.profile.givenName)
//            print(user.profile.familyName)
//            print(user.profile.email)
//            print(user.authentication.accessToken)
//            print(user.profile)
//        } else {
//            print("\(error.localizedDescription)")
//        }
//    }
//   func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
//                withError error: NSError!) {
//    }
//}
