//
//  DBManager.swift
//  PriceAggregator123
//
//  Created by student on 8/16/18.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DBManager {    
    var CDataArray = NSMutableArray()
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func saveData(DB: String, item: Item){
        let newItem = Favourites(context: self.context)
        newItem.id = item.id!
        newItem.descript = item.description
        newItem.name = item.name
        newItem.price = item.price!
        let coreDataObject = item.thumbnailImage?.coreDataRepresentation()
        if let retrievedImgArray = coreDataObject?.imageArray() {
            newItem.image = retrievedImgArray.coreDataRepresentation()
        }
        appDelegate?.saveContext()
    }

    func loadData(DB: String) -> [Item] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: DB)
        fetchRequest.returnsObjectsAsFaults = false
        var item = [Item]()
        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [Favourites] {
                let newItem = Item()
                newItem.descriptionItem = data.descript
                newItem.name = data.name
                newItem.price = data.price
                newItem.id = data.id
                newItem.thumbnailImage = data.image?.imageArray()
                item.append(newItem)
            }
        } catch {
            print("Failed")
        }
        return item
    }
    
    func removeData(DB: String, item: Item){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DB)
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [Favourites]
        for object in resultData {
            if object.id == item.id {
                context.delete(object)
            }
        }
        appDelegate?.saveContext()
    }
}


typealias ImageArray = [UIImage]

extension Array where Element: UIImage {
    func coreDataRepresentation() -> Data? {
        let CDataArray = NSMutableArray()
        
        for img in self {
            guard let imageRepresentation = UIImagePNGRepresentation(img) else {
                print("Unable to represent image as PNG")
                return nil
            }
            let data : NSData = NSData(data: imageRepresentation)
            CDataArray.add(data)
        }
        return NSKeyedArchiver.archivedData(withRootObject: CDataArray)
    }
}

extension Data {
    func imageArray() -> ImageArray? {
        if let mySavedData = NSKeyedUnarchiver.unarchiveObject(with: self) as? NSArray {
            let imgArray = mySavedData.flatMap({
                return UIImage(data: $0 as! Data)
            })
            return imgArray
        }
        else {
            print("Unable to convert data to ImageArray")
            return nil
        }
    }
}

