//
//  ViewController.swift
//  PriceAggregator
//
//  Created by student on 8/13/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

import SwiftyJSON

class DescriptionViewController: UIViewController {
    
    let apiKey = "jx9ztwc42y6mfvvhfa4y87hk"
    var cellImages = [UIImage](){
        didSet{
            DispatchQueue.main.async {
                self.itemImageCollection.reloadData()
                self.setDataToView()
            }
        }
    }

    let cellId = "DescribingCell"
    var itemId = "651779321"
    var item:Item = Item()
    
    @IBOutlet weak var itemImageCollection: UICollectionView!
    @IBOutlet weak var imagePageControl: UIPageControl!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.item.thumbnailImage = [String]()
        itemImageCollection.delegate = self
        itemImageCollection.dataSource = self
        itemImageCollection.isPagingEnabled = true
        imagePageControl.addTarget(self, action: #selector(pageControlTapHandler), for: .touchUpInside)
        priceLabel.text = "Price: "
        unparseDataAboutItem()
    }
    

    
    @objc func pageControlTapHandler(sender: UIPageControl){

        let index = IndexPath(item: sender.currentPage, section: 0)
       print(sender.currentPage)
        itemImageCollection.scrollToItem(at: index, at: [], animated: true)
    }
    
    func unparseDataAboutItem(){
        let urlString = "https://api.walmartlabs.com/v1/items/\(itemId)?apiKey=\(apiKey)&lsPublisherId=&format=json"
        let url = URL(string: urlString)
        let session = URLSession.shared
//        if let usingUrl = url{
//            session.dataTask(with: usingUrl) { (data, responce, error) in
//                do {
//                    let json = try JSON(data: data!)
//                    self.item.price = json["salePrice"].double!
//                    self.item.description = json["shortDescription"].string!
//                    self.item.name = json["name"].string!
//                    self.item.id = json["itemId"].int!
//                    self.item.name = json["name"].string!
//                    if json["imageEntities"].array != nil{
//                        if var appendingArr = self.item.thumbnailImage{
//                            for index in 0...json["imageEntities"].count - 1{
//                                let element = json["imageEntities"][index]["largeImage"].string!
//                                if !appendingArr.contains(element){
//                                    appendingArr.append(element)
//                                }
//                            }
//                            self.item.thumbnailImage = appendingArr
//                        }
//                    }else{
//                        self.item.thumbnailImage?.append(json["largeImage"].string!)
//                    }
//                    self.addImagesToCellImages()
//                } catch { }
//                }.resume()
//        }
     
    }

    func setDataToView(){
        priceLabel.text! = String("Price: \(item.price!)$")
        itemName.text = item.name!
        descriptionText.text = item.description!
    }
    
    func addImagesToCellImages(){
//        if let images = item.thumbnailImage{
//            for imageUrl in images{
//                let currUrl = URL(string: imageUrl)
//                URLSession.shared.dataTask(with: currUrl!) { (data, response, error) in
//                    if error != nil{
//                        print(error!)
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        self.cellImages.append(UIImage(data: data!)!)
//                    }
//
//
//
//                }.resume()
//            }
//        }
    }
}





extension DescriptionViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print((item.thumbnailImage?.count)!)
//        return (item.thumbnailImage?.count)!
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DescriptionCollectionViewCell
        cell.cellImage.contentMode = .scaleAspectFit
        imagePageControl.numberOfPages = cellImages.count
        cell.cellImage.image = cellImages[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        imagePageControl.currentPage = indexPath.row
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        print(x)
        imagePageControl.currentPage = Int((x / scrollView.frame.width).rounded())
    }
}

