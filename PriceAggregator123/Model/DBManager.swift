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

class DBManager{

    
    var favourites: [Favourites] = []
    var baskets: [Basket] = []
    var imgArray = [UIImage]()
    var CDataArray = NSMutableArray()
    
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    
    let favourite = Favourites(context: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!)
    let basket = Basket(context: ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!)

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    

func saveData(DB: String, item: Item){
        
            favourite.name = item.name
            favourite.id = Int64(item.id!)
            favourite.descript = item.description
            favourite.price = item.price!
            // save images
            let coreDataObject = imgArray.coreDataRepresentation()
            
            if let retrievedImgArray = coreDataObject?.imageArray() {
                favourite.setValue(retrievedImgArray, forKey: "thumbnailImage")
            }
        
            print("Saving data to context ...")
            appDelegate?.saveContext()
        }


    func loadData(DB: String)-> [Item] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DB)
        do {
            let results = try context.fetch(fetchRequest)
            return results as! [Item]
        } catch {
            print(error)
            return error as! [Item]
        }
        
        
        
    }
    
    
    func removeData(DB: String, item: Item){
  

        let item = item
        context.delete(item)


         //   favourites.fetchResultController.object(at: item)

        appDelegate?.saveContext()
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

