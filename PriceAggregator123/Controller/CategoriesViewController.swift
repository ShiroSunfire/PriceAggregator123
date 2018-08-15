//
//  CategoriesViewController.swift
//  PriceAggregator
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol CategoriesViewControllerDelegate {
    func searchButtonTapped(with id: String)
}

class CategoriesViewController: UITableViewController {

    @IBOutlet weak var searchButton: UIBarButtonItem!
    var delegate : CategoriesViewControllerDelegate?
    let categoriesUrl = "http://api.walmartlabs.com/v1/taxonomy?format=json&apiKey=jx9ztwc42y6mfvvhfa4y87hk"
    var jsonCategory : JSON?
    var id : String?
    var downloadJSON : Bool = false
    var refresh:RefreshImageView?
    var arrayCategories = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.isEnabled = false
        if !downloadJSON {
            getItems(currentUrl: URL(string: categoriesUrl)!)
        } else {
            self.jsonCategory = jsonCategory?["children"]
            setArrayCategories(json: jsonCategory!)
        }
        refresh = RefreshImageView(center: self.view.center)
        self.view.addSubview(refresh!)
    }
    
    func setArrayCategories(json: JSON) {
        arrayCategories.removeAll()
        var i = 0
        while json[i]["name"] != nil {
            self.arrayCategories.append(json[i]["name"].string!)
            i+=1
        }
    }
    
    func getItems(currentUrl: URL?) {
        guard let url = currentUrl else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            do {
                var json = try JSON(data: data!)
                json = json["categories"]
                self.jsonCategory = json
                self.setArrayCategories(json: json)
                self.downloadJSON = true
            } catch { }
        }.resume()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        delegate?.searchButtonTapped(with: id!)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let refresh = refresh {
            refresh.removeFromSuperview()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = arrayCategories[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if jsonCategory![indexPath.row]["children"] == nil {
            delegate?.searchButtonTapped(with: jsonCategory![indexPath.row]["id"].string!)
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        let anotherVC = storyboard?.instantiateViewController(withIdentifier: "categoriesVC") as! CategoriesViewController
        anotherVC.id = jsonCategory![indexPath.row]["id"].string
        anotherVC.downloadJSON = true
        anotherVC.jsonCategory = jsonCategory![indexPath.row]
        anotherVC.title = arrayCategories[indexPath.row]
        anotherVC.delegate = delegate
        self.navigationController?.pushViewController(anotherVC, animated: true)
    }
}
