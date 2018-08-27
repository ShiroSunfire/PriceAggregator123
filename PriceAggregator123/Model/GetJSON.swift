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
    private var getItemURL: (Int)->(String) = {
        return "https://api.walmartlabs.com/v1/items/\($0)?apiKey=\(APIKEY)&lsPublisherId=&format=json"
    }
    private var task: URLSessionTask?
    private var isCancel = false
    
    func getItems(with url: URL?, completion: @escaping (_ json: JSON) -> ()) {
        guard let url = url else { return }
        let session = URLSession.shared
        task = session.dataTask(with: url) { (data, responce, error) in
            do {
                if let currData = data{
                    let json = try JSON(data:currData)
                    completion(json)
                } else if (self.isCancel) {
                    self.isCancel = false
                } else {
                    completion(JSON.null)
                }
            } catch { print(error) }
        }
        task?.resume()
    }
    
    func cancelSession() {
        isCancel = true
        task?.cancel()
    }
    
    func getItems(with id: Int, imageLoaded: @escaping (UIImage) -> (),operationCompleted: @escaping ()->()) {
        guard let url = URL(string: getItemURL(id)) else {return}
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            if let existedData = data {
                do {
                    let json = try JSON(data: existedData)
                    self.getItemFromURL(json, imageLoaded: imageLoaded, operationCompleted: operationCompleted)
                } catch {
                    print("somithing wrong with JSON")
                }
            }
            }.resume()
        
    }
    
    private func getItemFromURL(_ json: JSON,imageLoaded: @escaping (UIImage)->(),operationCompleted: @escaping ()->())
    {
        if json["imageEntities"].array != nil{
            for index in 0...json["imageEntities"].count - 1{
                let element = json["imageEntities"][index]["largeImage"].string!
                guard let url = URL(string: element) else { return }
                downloadImage(with: url, completion: imageLoaded)
            }
        }
        operationCompleted()
    }
    
    func appendInArrayItem(json: JSON, i:Int) -> Item {
        let item = Item()
        item.id = json[i]["itemId"].int32!
        item.name = json[i]["name"].string!
        item.descriptionItem = json[i]["shortDescription"].string
        item.price = json[i]["salePrice"].double
        return item
    }
    
    func downloadImage(with url: URL, item: Item, completion: @escaping (UIImage, Item)->()) {
        let cuncurrent = DispatchQueue(label: "com.concurrent.quene", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        cuncurrent.async {
            let data = try? Data(contentsOf: url)
            if let imageData = data {
                completion(UIImage(data: imageData)!, item)
            }
        }
    }
    
    private func downloadImage(with url: URL, completion: @escaping (UIImage)->()) {
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










