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
    
    func getItems(with url: URL?, completion: @escaping (_ json: JSON) -> ()) {
        guard let url = url else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            do {
                let json = try JSON(data: data!)
                completion(json)
            } catch { }
        }.resume()
    }
    
    func appendInArrayItem(json: JSON, i:Int) -> Item {
        let item = Item()
        item.id = json[i]["itemId"].int32!
        item.name = json[i]["name"].string!
        item.descriptionItem = json[i]["shortDescription"].string
        item.price = json[i]["salePrice"].double
        return item
    }
    
    func downloadImage(with url: URL, i: Int, completion: @escaping (UIImage, Int)->()) {
        let data = try? Data(contentsOf: url)
        if let imageData = data {
            completion(UIImage(data: imageData)!, i)
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










