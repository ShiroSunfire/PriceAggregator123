//
//  AppDelegate.swift
//  PriceAggregator123
//
//  Created by student on 8/15/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit
import TwitterCore
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate  {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        TWTRTwitter.sharedInstance().start(withConsumerKey:"gu2dsasdsaTxasObYidfjsfux", consumerSecret:"ZasdasdfhgXcyPP0e5yrjNcsdffjshhabwh23xqlDbhjlfhUdd")
        
        GIDSignIn.sharedInstance().clientID = "501283990325-b879hgv8qdnci8j23duftjv89h234bps.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation]);

    }
    
    
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
                                            UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation!]
        return GIDSignIn.sharedInstance().handle(url as URL!,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        //  GIDSignIn.sharedInstance().signOut()
    }
    
}

