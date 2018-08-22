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

    var delegate : CategoriesViewControllerDelegate?
    private let categoriesUrl = "http://api.walmartlabs.com/v1/taxonomy?format=json&apiKey=jx9ztwc42y6mfvvhfa4y87hk"
    var categoryArray = [Category]()
    var isDownload = false
    private var refresh:RefreshImageView?
    private lazy var gjson = GetJSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCategories()
    }
    
    private func getCategories() {
        if !isDownload {
            refresh = RefreshImageView(center: CGPoint(x: self.view.center.x-70, y: self.view.center.y))
            self.view.addSubview(refresh!)
            getItems(currentUrl: URL(string: categoriesUrl)!)
            isDownload = true
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getCategoriesFromURL(_ json: JSON) {
        categoryArray = gjson.setCategories(json: json["categories"])
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getItems(currentUrl: URL?) {
        gjson.getItems(with: currentUrl, completion: getCategoriesFromURL(_:))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let refresh = refresh {
            refresh.removeFromSuperview()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if categoryArray[indexPath.row].childen.count == 0 {
            delegate?.searchButtonTapped(with: categoryArray[indexPath.row].id!)
            delegate?.needCloseLastSubviews()
            while let child = self.parent?.childViewControllers.first {
                child.removeFromParentViewController()
            }
            return
        }
        openNewCategoryVC(indexPath: indexPath)
    }
    
    private func openNewCategoryVC(indexPath: IndexPath) {
        let rectOfCell = tableView.rectForRow(at:(indexPath))
        let rectOfCellInSuperview = tableView.convert(rectOfCell, to: tableView.superview)
        guard let categoriesVC = storyboard?.instantiateViewController(withIdentifier: "categoriesVC") as? CategoriesViewController else { return }
        categoriesVC.isDownload = isDownload
        categoriesVC.categoryArray = categoryArray[indexPath.row].childen
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
