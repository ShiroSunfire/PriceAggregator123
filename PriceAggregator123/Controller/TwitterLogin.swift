////
////  TwitterLogin.swift
////  PriceAggregator123
////
////  Created by student on 8/21/18.
////  Copyright © 2018 student. All rights reserved.
////
//
//import Foundation
//import TwitterKit
//
//
//class TwitterLogin{
//    
//    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
//
//    func twitterConnect(){
//        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
//        if (session != nil) {
//            print("signed in as \(String(describing: session?.userName))");
//            print("userID \(String(describing: session?.userID))");
//            LoginViewController().saveID(id: String(describing: session?.userID))
//        } else {
//            print("error: \(String(describing: error?.localizedDescription))");
//        }
//        })
//    }
//}
