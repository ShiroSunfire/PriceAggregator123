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

    @IBOutlet weak var labelShowForUser: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var urlCreate : [String:String] = ["query":"", "numItems":"10", "format":"json", "apiKey":"jx9ztwc42y6mfvvhfa4y87hk"]
    var jsonItems :JSON?
    var url = "http://api.walmartlabs.com/v1/search?"
    var categoryId = ""
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
//        let refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .blue
//        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        collectionView.addSubview(refreshControl)
//        collectionView.alwaysBounceVertical = true
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
        return URL(string: newURL)
    }
    
    func getItems(with url: URL?) {
        guard let url = url else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            do {
                let json = try JSON(data: data!)
                self.jsonItems = json["items"]
                var i = 0
                while json["items"][i] != nil && i<10 {
                    self.appendInArrayItem(json: json["items"], i: i)
                    i+=1
                }
            } catch { }
        }.resume()
    }
    
    func appendInArrayItem(json: JSON, i:Int) {
        let item = Item()
        item.id = json[i]["itemId"].int!
        item.name = json[i]["name"].string!
        item.description = json[i]["shortDescription"].string
        item.price = json[i]["salePrice"].double
        self.arrayItems.append(item)
        self.downloadImage(with: URL(string: json[i]["thumbnailImage"].string!)!, i: arrayItems.count - 1)
    }
    
    func downloadImage(with url: URL, i: Int) {
        let data = try? Data(contentsOf: url)
        if let imageData = data {
            self.arrayItems[i].thumbnailImage = UIImage(data: imageData)
        }
    }
    
    @IBAction func categoriesButtonTapped(_ sender: UIButton) {
        guard let categoriesVC = storyboard?.instantiateViewController(withIdentifier: "categoriesVC") as? CategoriesViewController else { return }
        categoriesVC.delegate = self
        self.navigationController?.pushViewController(categoriesVC, animated: true)
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
        if let refresh = refresh {
            refresh.removeFromSuperview()
        }
        labelShowForUser.isHidden = true
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NormalCell
        cell.labelDescription.text = arrayItems[indexPath.row].name!
        cell.image.image = arrayItems[indexPath.row].thumbnailImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 80)
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
        delegate?.cellWasTapped(id: arrayItems[indexPath.row].id!)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        refresh = RefreshImageView(center: self.view.center)
        self.view.addSubview(refresh!)
        searchBar.endEditing(true)
        urlCreate["query"] = searchBar.text!
        arrayItems.removeAll()
        getItems(with: getURL())
    }
}

extension SearchViewController: CategoriesViewControllerDelegate {
    func searchButtonTapped(with id: String) {
        refresh = RefreshImageView(center: self.view.center)
        self.view.addSubview(refresh!)
        arrayItems.removeAll()
        getItems(with: URL(string: "http://api.walmartlabs.com/v1/paginated/items?format=json&category=\(id)&apiKey=jx9ztwc42y6mfvvhfa4y87hk")!)
    }
}








