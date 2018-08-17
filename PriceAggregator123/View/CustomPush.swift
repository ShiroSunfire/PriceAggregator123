//
//  CustomPush.swift
//  PriceAggregator123
//
//  Created by student on 8/17/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CustomPush: NSObject {
    
    var cell = UIView()
    
    var startingPoint = CGPoint.zero{
        didSet{
            cell.center = startingPoint
        }
    }
    
    var cellColor = UIColor.white
    
    var duration = 0.5
    
//    enum Circular
}
