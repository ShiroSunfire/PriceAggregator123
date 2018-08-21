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
    func needCloseLastSubviews()
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
        refresh = RefreshImageView(center: CGPoint(x: self.view.center.x-70, y: self.view.center.y))
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
            delegate?.needCloseLastSubviews()
            while let child = self.parent?.childViewControllers.first {
                child.removeFromParentViewController()
            }
            return
        }
        let rectOfCell = tableView.rectForRow(at:(indexPath))
        let rectOfCellInSuperview = tableView.convert(rectOfCell, to: tableView.superview)
        guard let categoriesVC = storyboard?.instantiateViewController(withIdentifier: "categoriesVC") as? CategoriesViewController else { return }
        categoriesVC.id = jsonCategory![indexPath.row]["id"].string
        categoriesVC.downloadJSON = true
        categoriesVC.jsonCategory = jsonCategory![indexPath.row]
        categoriesVC.delegate = delegate
        categoriesVC.view.frame.size = CGSize(width: tableView.frame.size.width, height: 40)
        categoriesVC.view.frame.origin = CGPoint(x: 0, y: rectOfCellInSuperview.minY)
        let newView = TouchView(frame: CGRect(origin: CGPoint(x: 0, y: self.view.frame.origin.y), size: CGSize(width: (self.view.superview?.frame.size.width)!, height: self.view.frame.size.height)))
        newView.delegate = self.parent as! SearchViewController
        newView.backgroundColor = UIColor.black
        newView.alpha = 0.2
        self.view.superview!.addSubview(newView)
        self.parent!.addChildViewController(categoriesVC)
        self.parent!.view.addSubview(categoriesVC.view)
        UIView.animate(withDuration: 1) {
            categoriesVC.view.frame.size = CGSize(width: 230, height: self.view.frame.size.height)
            categoriesVC.view.frame.origin = CGPoint(x: 0, y: self.view.frame.origin.y)
        }
    }
}
