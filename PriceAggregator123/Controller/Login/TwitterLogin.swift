//
//  TwitterLogin.swift
//  PriceAggregator123
//
//  Created by student on 8/21/18.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation
import TwitterKit

protocol TwitterLoginDelegate{
    var userID: String {get set}
}
class TwitterLogin{

    var delegate: TwitterLoginDelegate?

    func twitterConnect(){
        getInfo()
    }
    
    private func getInfo(){
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                print("userID \(String(describing: session?.userID))");
                self.delegate?.userID = String(describing: session?.userID)
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }
}
