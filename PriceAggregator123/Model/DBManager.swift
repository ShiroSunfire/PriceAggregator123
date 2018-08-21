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
    
    func saveData(DB: String, item: Item){
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: DB)
        fetchRequest.returnsObjectsAsFaults = false
        
        if DB == "Favourites"{
            let newItem = Favourites(context: context)

            do {
                let result = try context.fetch(fetchRequest)
                for data in result as! [Favourites] {
                    if item.id == data.id{
                       return
                    }
                }
                newItem.id = item.id!
                newItem.descript = item.descriptionItem!
                newItem.name = item.name
                newItem.price = item.price!
                let coreDataObject = item.thumbnailImage?.coreDataRepresentation()
                if let retrievedImgArray = coreDataObject?.imageArray() {
                    newItem.image = retrievedImgArray.coreDataRepresentation()
                }
            } catch{
                print("Error")
            }
            saveContext()
        } else {
            do {
                let result = try context.fetch(fetchRequest)
                for data in result as! [Basket] {
                    if item.id == data.id{
                        data.quantity += 1
                        saveContext()
                        return
                    }
                }
                let newItem = Basket(context: context)
                newItem.id = item.id!
                newItem.descript = item.descriptionItem!
                newItem.name = item.name
                newItem.price = item.price!
                newItem.quantity = 1
                let coreDataObject = item.thumbnailImage?.coreDataRepresentation()
                if let retrievedImgArray = coreDataObject?.imageArray() {
                    newItem.image = retrievedImgArray.coreDataRepresentation()
                }
                saveContext()
            } catch{
                print("Error")
            }
        }
    }
    
    func loadData(DB: String) -> [Item] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: DB)
        fetchRequest.returnsObjectsAsFaults = false
        let context = self.persistentContainer.viewContext
        var item = [Item]()
        do {
            let result = try context.fetch(fetchRequest)
            if DB == "Favourites" {
                for data in result as! [Favourites] {
                    let newItem = Item()
                    newItem.descriptionItem = data.descript
                    newItem.name = data.name
                    newItem.price = data.price
                    newItem.id = data.id
                    newItem.thumbnailImage = data.image?.imageArray()
                    item.append(newItem)
                }
            } else {
                for data in result as! [Basket] {
                    let newItem = Item()
                    newItem.descriptionItem = data.descript
                    newItem.name = data.name
                    newItem.price = data.price
                    newItem.id = data.id
                   newItem.quantity = Int(data.quantity)
                    newItem.thumbnailImage = data.image?.imageArray()
                    item.append(newItem)
                }
            }
        } catch {
            print("Failed")
        }
        print(item)
        return item
    }
    
    func removeData(DB: String, item: Item){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DB)
        let context = self.persistentContainer.viewContext
        let result = try? context.fetch(fetchRequest)
        if DB == "Favourites" {
            let resultData = result as! [Favourites]
            for object in resultData {
               if object.id == item.id {
                    context.delete(object)
                }
            }
        } else{
            let resultData = result as! [Basket]
            for object in resultData {
                if object.id == item.id {
                    context.delete(object)
                }
            }
        }
        saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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
