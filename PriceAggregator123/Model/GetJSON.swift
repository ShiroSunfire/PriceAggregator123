//
//  File.swift
//  PriceAggregator123
//
//  Created by student on 8/21/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import SwiftyJSON


class GetJSON {
    private static let APIKEY = "jx9ztwc42y6mfvvhfa4y87hk"
    
    var getItemURL: (Int)->(String) = {
        return "https://api.walmartlabs.com/v1/items/\($0)?apiKey=\(APIKEY)&lsPublisherId=&format=json"
    }
    
    
    func getItems(with url: URL?, completion: @escaping (_ json: JSON) -> ()) {
        guard let url = url else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            do {
                if let currData = data{
                    let json = try JSON(data:currData)
                    completion(json)
                }
                else {
                    completion(JSON.null)
                }
            } catch { print(error) }
        }.resume()
    }
    
    
    func getItems(with id: Int, imageLoaded: @escaping (UIImage) -> (),operationCompleted: @escaping ()->(),isNil:Bool)  {
        guard let url = URL(string: getItemURL(id)) else {return}
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            if let existedData = data {
                do {
                    let json = try JSON(data: existedData)
                    self.getItemFromURL(json, imageLoaded: imageLoaded, operationCompleted: operationCompleted, isNil: isNil)
                } catch {
                    
                }
                
            }
            }.resume()
        
    }
    
    private func getItemFromURL(_ json: JSON,imageLoaded: @escaping (UIImage)->(),operationCompleted: @escaping ()->(),isNil:Bool) {
        if isNil{
            guard let url = URL(string: json["largeImage"].string!) else {return}
            downloadImage(with: url, completion: imageLoaded)
            
            operationCompleted()
        }else{
            if json["imageEntities"].array != nil{
                for index in 0...json["imageEntities"].count - 1{
                    let element = json["imageEntities"][index]["largeImage"].string!
                    guard let url = URL(string: element) else { return }
                    downloadImage(with: url, completion: imageLoaded)
                }
            }
            operationCompleted()
        }
        
    }
    
    func appendInArrayItem(json: JSON, i:Int) -> Item {
        let item = Item()
        item.id = json[i]["itemId"].int32!
        item.name = json[i]["name"].string!
        item.descriptionItem = json[i]["shortDescription"].string
        item.price = json[i]["salePrice"].double
        return item
    }
    
    func downloadImage(with url: URL, i: Int = 0, completion: @escaping (UIImage, Int)->()) {
        let data = try? Data(contentsOf: url)
        if let imageData = data {
            completion(UIImage(data: imageData)!, i)
        }
    }
    
    func downloadImage(with url: URL, completion: @escaping (UIImage)->()) {
        let data = try? Data(contentsOf: url)
        if let imageData = data {
            completion(UIImage(data: imageData)!)
        }
    }
    
    func setCategories(json: JSON) -> [Category] {
        var categoriesArray = [Category]()
        var i = 0
        while json[i] != JSON.null {
            let category = Category()
            category.id = json[i]["id"].string!
            category.name = json[i]["name"].string!
            if json[i]["children"] != JSON.null {
                category.childen = setCategories(json: json[i]["children"])
            }
            categoriesArray.append(category)
            i += 1
        }
        return categoriesArray
    }
}










