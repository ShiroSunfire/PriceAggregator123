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

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
         let userID = user.userID
            print(userID)
            saveID(id: userID!)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    
    @IBOutlet weak var accountImage: UIImageView!
    
    var dict : [String : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gidSingIn = GIDSignIn()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        gidSingIn.delegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    
    @IBAction func fbLog(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.getFBUserData()
            }
        }
    }
    
    
    
    @IBAction func twLog(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
                print("userID \(String(describing: session?.userID))");
                self.saveID(id: String(describing: session?.userID))
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
        
    }
    
    @IBAction func gmLog(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
       
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            print(user.userID)                // For client-side use only!
            saveID(id: user.userID)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
    }
    
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    let id = self.dict["id"]
                    self.saveID(id: id as! String)
                }
            })
        }
    }
    
    
    func saveID(id: String){
        UserDefaults.standard.set(id, forKey: "UserID")
        self.dismiss(animated: true, completion: nil)
    }
}
