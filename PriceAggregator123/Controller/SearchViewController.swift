//
//  ViewController.swift
//  PriceAggregator
//
//  Created by student on 8/13/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol SearchViewControllerDelegate {
    func cellWasTapped(id:Int)
}

class SearchViewController: UIViewController {

    @IBOutlet weak var fromPrice: UITextField!
    @IBOutlet weak var toPrice: UITextField!
    @IBOutlet weak var labelShowForUser: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var urlCreate : [String:String] = ["query":"", "numItems":"10", "facetRange":"", "format":"json", "apiKey":"jx9ztwc42y6mfvvhfa4y87hk"]
    var jsonItems :JSON?
    var url = "http://api.walmartlabs.com/v1/search?"
    var categoryId = ""
    var nibShow = "Normal"
    var refresh:RefreshImageView?
    var delegate: SearchViewControllerDelegate?
    var arrayItems = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "UserID") == nil {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Load") as! LoginViewController
            self.present(controller, animated: true, completion: nil)
        }
        //collectionView.register(UINib(nibName: "RectangleCell", bundle: nil), forCellWithReuseIdentifier: "RectangleCell")
        collectionView.register(UINib(nibName: "NormalCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func getURL() -> URL? {
        var newURL = url + "query" + "=" + urlCreate["query"]!.replacingOccurrences(of: " ", with: "", options: [])
        newURL += "&" + "start" + "=" + String(arrayItems.count + 1)
        newURL += "&" + "numItems" + "=" + urlCreate["numItems"]!
        newURL += "&" + "format" + "=" + urlCreate["format"]!
        newURL += "&" + "apiKey" + "=" +  urlCreate["apiKey"]!
        if urlCreate["facetRange"] != "" {
            newURL += urlCreate["facetRange"]!
        }
        return URL(string: newURL)
    }
    
    func getItems(with url: URL?) {
        guard let url = url else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            do {
                let json = try JSON(data: data!)
                if json["totalResults"].int == 0 {
                    DispatchQueue.main.async {
                        self.refresh?.removeFromSuperview()
                        self.refresh = nil
                        let alert = UIAlertController(title: "No items found, please try another products", message: "", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                    return
                }
                self.jsonItems = json["items"]
                var i = 0, j = 0
                while json["items"][i] != nil && i<10 {
//                    if !json["items"][i]["availableOnline"].bool! {
//                        j-=1
//                        return
//                    }
                    self.appendInArrayItem(json: json["items"], i: j)
                    i+=1
                    j+=1
                }
            } catch { }
        }.resume()
    }
    
    func appendInArrayItem(json: JSON, i:Int) {
        print(json[i]["availableOnline"])
        let item = Item()
        item.id = json[i]["itemId"].int32!
        item.name = json[i]["name"].string!
        item.descriptionItem = json[i]["shortDescription"].string
        item.price = json[i]["salePrice"].double
        self.arrayItems.append(item)
        self.downloadImage(with: URL(string: json[i]["thumbnailImage"].string!)!, i: arrayItems.count - 1)
    }
    
    func downloadImage(with url: URL, i: Int) {
        let data = try? Data(contentsOf: url)
        if let imageData = data {
            if arrayItems.count <= i {
                return
            }
            self.arrayItems[i].thumbnailImage = [UIImage]()
            self.arrayItems[i].thumbnailImage?.append(UIImage(data: imageData)!)
        }
    }
    
    @IBAction func categoriesButtonTapped(_ sender: UIButton) {
        guard let categoriesVC = storyboard?.instantiateViewController(withIdentifier: "categoriesVC") as? CategoriesViewController else { return }
        categoriesVC.delegate = self
        self.navigationController?.pushViewController(categoriesVC, animated: true)
    }
    
//    func getSortArray(filter: String) {
//        if refresh == nil {
//            refresh = RefreshImageView(center: self.view.center)
//            self.view.addSubview(refresh!)
//        }
//        arrayItems.removeAll()
//        if urlCreate["sortOption"] == filter {
//            if urlCreate["order"] == "&order=desc" {
//                urlCreate["order"] = "&order=asc"
//            } else {
//                urlCreate["order"] = "&order=desc"
//            }
//        } else {
//            urlCreate["sortOption"] = filter
//            urlCreate["order"] = "&order=asc"
//        }
//        getItems(with: getURL())
//    }

//    @IBAction func priceFilterButtonTapped(_ sender: Any) {
//        getSortArray(filter: "&facet=on&facet.range=price:[0%20TO%2010000]&sort=price")
//    }
//
//    @IBAction func newFilterButtonTapped(_ sender: Any) {
//        getSortArray(filter: "&facet=on&facet.range=price:[0%20TO%2010000]&sort=new")
//    }
//
//    @IBAction func bestSellerFilterButtonTapped(_ sender: Any) {
//        getSortArray(filter: "&facet=on&facet.range=price:[0%20TO%2010000]&sort=bestseller")
//    }
    
    @IBAction func cancelFilters(_ sender: Any) {
        arrayItems.removeAll()
        urlCreate["facetRange"] = ""
        if refresh == nil {
            refresh = RefreshImageView(center: self.view.center)
            self.view.addSubview(refresh!)
        }
        getItems(with: getURL())
    }
    
    @IBAction func choseCellButton(_ sender: Any) {
        if nibShow == "Normal" {
            collectionView.register(UINib(nibName: "RectangleCell", bundle: nil), forCellWithReuseIdentifier: "RectangleCell")
            nibShow = "Rectangle"
        } else if nibShow == "Rectangle" {
            collectionView.register(UINib(nibName: "NormalCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            nibShow = "Normal"
        }
        collectionView.reloadData()
    }
    
    @IBAction func filterPrice(_ sender: Any) {
        fromPrice.endEditing(true)
        toPrice.endEditing(true)
        arrayItems.removeAll()
        var from = Int(fromPrice.text!)
        if from == nil {
            from = 0
        }
        var to = Int(toPrice.text!)
        if to == nil {
            to = 10000
        }
        urlCreate["facetRange"] = "&facet.range=price:[\(from!)%20TO%20\(to!)]"
        refresh = RefreshImageView(center: self.view.center)
        self.view.addSubview(refresh!)
        getItems(with: getURL())
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if refresh != nil {
            refresh!.removeFromSuperview()
            refresh = nil
        }
        labelShowForUser.isHidden = true
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NormalCell
        if nibShow == "Rectangle" {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RectangleCell", for: indexPath) as! NormalCell
        }
        cell.delegate = self
        cell.labelDescription.text = arrayItems[indexPath.row].name!
        cell.item = arrayItems[indexPath.row]
        cell.image.image = arrayItems[indexPath.row].thumbnailImage?.first
        cell.priceLabel.text = "$" + String(arrayItems[indexPath.row].price!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if nibShow == "Normal" {
            return CGSize(width: view.frame.size.width, height: 80)
        } else { //if nibShow == "Rectangle" {
            return CGSize(width: view.frame.size.width/2, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row)
        if arrayItems.count % 10 == 0 && indexPath.row == (arrayItems.count - 1) && searchBar.text! != "" {
            print("Refresh data")
            getItems(with: getURL())
        } else if arrayItems.count % 10 == 0 && indexPath.row == (arrayItems.count - 1) {
            print("Resresh data category")
            let dispatch = DispatchQueue(label: "com.concurrent.quene", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.never, target: nil)
            dispatch.async {
                let count = self.arrayItems.count
                var i = count
                while i < count+10 && self.jsonItems![i] != nil {
                    self.appendInArrayItem(json: self.jsonItems!, i: i)
                    i+=1
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Description", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DescriptionVC") as! DescriptionViewController
        delegate = controller
        delegate?.cellWasTapped(id: Int(arrayItems[indexPath.row].id!))
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if refresh == nil {
            refresh = RefreshImageView(center: self.view.center)
            self.view.addSubview(refresh!)
        }
        labelShowForUser.isHidden = true
        searchBar.endEditing(true)
        urlCreate["query"] = searchBar.text!
        arrayItems.removeAll()
        getItems(with: getURL())
    }
}

extension SearchViewController: CategoriesViewControllerDelegate {
    func searchButtonTapped(with id: String) {
        if refresh == nil {
            refresh = RefreshImageView(center: self.view.center)
            self.view.addSubview(refresh!)
        }
        arrayItems.removeAll()
        getItems(with: URL(string: "http://api.walmartlabs.com/v1/paginated/items?format=json&category=\(id)&apiKey=jx9ztwc42y6mfvvhfa4y87hk")!)
    }
}

extension SearchViewController: NormalCellDelegate {
    func buyButtonTapped(db: String) {
        let alert = UIAlertController(title: "Item added to basket", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func favoriteButtonTapped(db: String) {
        let alert = UIAlertController(title: "Item added to favorite", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}






