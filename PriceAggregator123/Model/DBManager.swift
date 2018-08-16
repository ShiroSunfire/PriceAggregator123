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
    var favourites: [Favourites] = []
    //var baskets: [Basket] = []
    var imgArray = [UIImage]()
    var CDataArray = NSMutableArray()
    
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    
    let favourite = Favourites(context: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!)
    //let basket = Basket(context: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!)

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func saveData(DB: String, item: Item){
        favourite.name = item.name
        favourite.id = Int64(item.id!)
        favourite.descript = item.description
        favourite.price = item.price!
//        let coreDataObject = imgArray.coreDataRepresentation()
//        if let retrievedImgArray = coreDataObject?.imageArray() {
//            favourite.setValue(retrievedImgArray, forKey: "thumbnailImage")
//        }
        print("Saving data to context ...")
        appDelegate?.saveContext()
    }

    func loadData(DB: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: DB)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data)
            }
        } catch {
            print("Failed")
        }

    }
    
    
    func removeData(DB: String, item: Item){
        let restaurantToDelete = self.fetchResultController.object(at:
            item)
        context.delete(restaurantToDelete)
      
        
//        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: DB)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//        do {
//            try context.execute(deleteRequest)
//            try context.save()
//        } catch {
//            print ("There is an error in deleting records")
//        }
        do {
            context.delete(item)
            appDelegate!.saveContext()
        } catch {

        }
    }
}


typealias ImageArray = [UIImage]
typealias ImageArrayRepresentation = Data

extension Array where Element: UIImage {
    func coreDataRepresentation() -> ImageArrayRepresentation? {
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

extension ImageArrayRepresentation {
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

