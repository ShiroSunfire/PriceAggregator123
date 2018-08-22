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
    
    private var CDataArray = NSMutableArray()
    
    enum Databases:String{
        case basket = "Basket"
        case favorites = "Favourites"
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
    
    func addItemToDatabase(context: NSManagedObjectContext, database:Databases,item:Item) -> Void {
        switch database {
        case .basket:
            let newItem = getDatabaseWithContext(context: context, Database: database) as! Basket
            newItem.configure(item: item)
            
        case .favorites:
            let newItem = getDatabaseWithContext(context: context, Database: database) as! Favourites
            newItem.configure(item: item)
        default:
            return
        }
        
        
    }
    
    
    func saveData(database:Databases, item: Item){
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: database.rawValue)
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let fetchedResult = try context.fetch(fetchRequest)
            switch  database {
                
            case .basket:
                if let itemsArray = fetchedResult as? [Basket]{
                    for anItem in itemsArray{
                        if anItem.id == item.id!{
                            itemsArray.first?.quantity += 1
                            saveContext()
                            return
                        }
                    }
                }
                
                
            case .favorites:
                if let itemsArray = fetchedResult as? [Favourites]{
                    for anItem in itemsArray{
                        if anItem.id == item.id!{
                            return
                        }
                    }
                }
                
                
            default:
                return
            }
            addItemToDatabase(context: context, database: database, item: item)
        }catch{
            print("smth goes wrong")
        }
        
        saveContext()
        
    }
    
    
    func getDatabaseWithContext(context:NSManagedObjectContext,Database:Databases) ->NSManagedObject?{
        switch Database {
        case .basket:
            return Basket(context: context)
        case .favorites:
            return Favourites(context: context)
        default:
            return nil
        }
    }
    
    func loadData(from database:Databases) -> [Item] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: database.rawValue)
        fetchRequest.returnsObjectsAsFaults = false
        let context = self.persistentContainer.viewContext
        var item = [Item]()
        do {
            let result = try context.fetch(fetchRequest)
            if database == .favorites {
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
    
    func removeData(from database:Databases, item: Item){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: database.rawValue)
        let context = self.persistentContainer.viewContext
        let result = try? context.fetch(fetchRequest)
        if database == .favorites {
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

extension Basket{
    func configure(item:Item){
        self.id = item.id!
        self.descript = item.descriptionItem!
        self.name = item.name
        self.price = item.price!
        self.quantity = 1
        let coreDataObject = item.thumbnailImage?.coreDataRepresentation()
        if let retrievedImgArray = coreDataObject?.imageArray() {
            self.image = retrievedImgArray.coreDataRepresentation()
        }
    }
}

extension Favourites{
    func configure(item:Item){
        self.id = item.id!
        self.descript = item.descriptionItem!
        self.name = item.name
        self.price = item.price!
        let coreDataObject = item.thumbnailImage?.coreDataRepresentation()
        if let retrievedImgArray = coreDataObject?.imageArray() {
            self.image = retrievedImgArray.coreDataRepresentation()
        }
    }
}
