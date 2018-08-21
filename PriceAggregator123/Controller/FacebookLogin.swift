////
////  FacebookLogin.swift
////  PriceAggregator123
////
////  Created by student on 8/21/18.
////  Copyright © 2018 student. All rights reserved.
////
//
//import UIKit
//import FBSDKCoreKit
//import FBSDKShareKit
//import FBSDKLoginKit
//import FacebookLogin
//
//protocol FacebookLoginDelegate{
//    var userID: String {get set}
//}
//
//class FacebookLogin {
//
//   private var dict : [String : AnyObject]!
//
//   var delegate: FacebookLoginDelegate?
//
//  private func fbConnect(){
//        let loginManager = LoginManager()
//        loginManager.logIn(readPermissions: [ .publicProfile ], viewController: LoginViewController()) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                self.getFBUserData()
//            }
//        }
//    }
//
// private func getFBUserData(){
//        if((FBSDKAccessToken.current()) != nil){
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//                if (error == nil){
//                    self.dict = result as! [String : AnyObject]
//                    print(result!)
//                    let id = self.dict["id"]
//                   //saveID(id: id as! String)
//                }
//            })
//        }
//    }
//}
