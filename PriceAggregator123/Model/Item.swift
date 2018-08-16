//
//  Item.swift
//  PriceAggregator
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Item: NSManagedObject {
    var id:Int32?
    var price:Double?
    var thumbnailImage: [UIImage]?
    var name: String?
    var descriptionItem: String?
}
