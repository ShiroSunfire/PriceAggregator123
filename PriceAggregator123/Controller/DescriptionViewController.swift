//
//  ViewController.swift
//  PriceAggregator
//
//  Created by student on 8/13/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol DescriptionViewControllerDelegate {
    func addItemToBasket(item: Item)
}


class DescriptionViewController: UIViewController {
    
    let apiKey = "jx9ztwc42y6mfvvhfa4y87hk"
    let cellId = "DescribingCell"
    var itemId:Int!
    var item:Item = Item()
    var scaledImageView:AnimationView!{
        didSet{
            addSwipeGestureForScaledImage()
            addTapGestureForScaledImage()
        }
    }
    
    @IBOutlet weak var itemImageCollection: UICollectionView!
    @IBOutlet weak var imagePageControl: UIPageControl!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToBasketButton: UIButton!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    
    var delegate:DescriptionViewControllerDelegate?
    
    var refresh: RefreshImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.item.thumbnailImage = [UIImage]()
        itemName.textAlignment = .center
        itemImageCollection.delegate = self
        itemImageCollection.dataSource = self
        itemImageCollection.isPagingEnabled = true
        imagePageControl.addTarget(self, action: #selector(pageControlTapHandler), for: .touchUpInside)
        priceLabel.text = ""
        self.title = "Description"
    }
    
    @IBAction func addToBasketPressed(_ sender: UIButton) {
    }
    @IBAction func addToFavoritesPressed(_ sender: UIButton) {
    }
    
    @objc func pageControlTapHandler(sender: UIPageControl){
        
        let index = IndexPath(item: sender.currentPage, section: 0)
        print(sender.currentPage)
        itemImageCollection.scrollToItem(at: index, at: [], animated: true)
    }
    
    func unparseDataAboutItem(){
        let urlString = "https://api.walmartlabs.com/v1/items/\(itemId!)?apiKey=\(apiKey)&lsPublisherId=&format=json"
        let url = URL(string: urlString)
        let session = URLSession.shared
        if let usingUrl = url{
            session.dataTask(with: usingUrl) { (data, responce, error) in
                do {
                    let json = try JSON(data: data!)
                    
                    if let price = json["salePrice"].double{
                        self.item.price = price
                    }else{self.item.price = 0.0}
                    
                    if let description = json["shortDescription"].string{
                        self.item.descriptionItem = description
                    }else{ self.item.descriptionItem = "Description not available" }
                    
                    if let name = json["name"].string{
                        self.item.name = name
                    }else{ self.item.name = "<blank>"}
                    
                    self.item.id = json["itemId"].int32!
                    
                    if json["imageEntities"].array != nil{
                        if self.item.thumbnailImage != nil{
                            for index in 0...json["imageEntities"].count - 1{
                                let element = json["imageEntities"][index]["largeImage"].string!
                                self.downloadImage(with: element, to: self.item)
                            }
                        }
                    }else{
                        
                        self.downloadImage(with: json["largeImage"].string!, to: self.item)
                    }
                    self.addImagesToCellImages()
                } catch {}
                }.resume()
        }
        
    }
    
    func downloadImage(with url:String,to item:Item){
        let currUrl = URL(string: url)
        URLSession.shared.dataTask(with: currUrl!) { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data!){
                    item.thumbnailImage?.append(image)
                    self.addImagesToCellImages()
                    self.refresh?.removeFromSuperview()
                }
            }
            }.resume()
    }
    
    func setDataToView(){
        priceLabel.text! = String("Price: \(item.price!)$")
        itemName.text = item.name!
        descriptionText.text = item.descriptionItem!
        addToFavoritesButton.setTitle("To Favorites", for: .normal)
        addToBasketButton.setTitle("to Basket", for: .normal)
    }
    
    func addImagesToCellImages(){
        if item.thumbnailImage != nil{
            DispatchQueue.main.async {
                self.itemImageCollection.reloadData()
                self.setDataToView()
            }
        }
    }
}





extension DescriptionViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (item.thumbnailImage?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DescriptionCollectionViewCell
        cell.cellImage.contentMode = .scaleAspectFit
        imagePageControl.numberOfPages = (item.thumbnailImage?.count)!
        cell.cellImage.image = item.thumbnailImage?[indexPath.row]
        cell.delegate = self
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
}

extension DescriptionViewController: SearchViewControllerDelegate{
    func cellWasTapped(id: Int) {
        itemId = id
        refresh = RefreshImageView(center: self.view.center)
        self.view.addSubview(refresh)
        unparseDataAboutItem()
    }
}


extension DescriptionViewController: DescriptionCellDelegate{
    func cellTaped(sender: UITapGestureRecognizer) {
        if let collectionCell = sender.view as? DescriptionCollectionViewCell{
            if collectionCell.isFullScreeen{
                scaledImageView = AnimationView(frame: view.frame, frontImage: collectionCell.cellImage.image!)
                self.view.addSubview(self.scaledImageView)
                scaledImageView.alpha = 0.0
                UIView.animate(withDuration: 1.0) {
                    self.view.bringSubview(toFront: self.scaledImageView)
                    self.scaledImageView.alpha = 1.0
                    self.scaledImageView.isUserInteractionEnabled = true
                }
//                self.view.bringSubview(toFront: self.scaledImageView)
//                self.scaledImageView.alpha = 1.0
//                scaledImageView.isUserInteractionEnabled = true
            }
        }
    }
    
    func addTapGestureForScaledImage(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(scaledImageTapHandler(sender:)))
        scaledImageView?.addGestureRecognizer(tap)
    }
    
    func addSwipeGestureForScaledImage(){
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(scaledImageSwipeHandler(sender: )))
        swipeGestureLeft.direction = .left
        scaledImageView?.addGestureRecognizer(swipeGestureLeft)
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(scaledImageSwipeHandler(sender: )))
        swipeGestureRight.direction = .right
        scaledImageView?.addGestureRecognizer(swipeGestureRight)
    }
    
    
    
    @objc func scaledImageTapHandler(sender: UITapGestureRecognizer){
        
        UIView.animate(withDuration: 1.0, animations: {
            self.scaledImageView.alpha = 0.0
        }) { (_) in
            sender.view?.removeFromSuperview()
            self.scaledImageView = nil
        }
    }
    
    @objc func scaledImageSwipeHandler(sender:  UISwipeGestureRecognizer){
        var layerImage:CGImage!
        if let castedView = sender.view as? AnimationView{
                layerImage = castedView.isFliped ? castedView.bottomLayer.contents as! CGImage : castedView.topLayer.contents as! CGImage
        }
        var imageIndex = 0
//        item.thumbnailImage.con
        for index in 0...(item.thumbnailImage?.count)! - 1{
            if item.thumbnailImage![index].cgImage == layerImage{
                break
            }
            imageIndex += 1
        }
        
        if sender.direction == .right{
            if imageIndex > 0{
                if (sender.view as? AnimationView) != nil{
                    scaledImageView.flip(to: AnimationView.Direction.left, with: item.thumbnailImage![imageIndex - 1])
//                    scaledImageView.changeLayers()
                }
            }
            
        } else if sender.direction == .left{
            if imageIndex <   (item.thumbnailImage?.count)! - 1{
                if (sender.view as? AnimationView) != nil{
                    scaledImageView.flip(to: AnimationView.Direction.left, with: item.thumbnailImage![imageIndex + 1])
//                    scaledImageView.changeLayers()
                }
            }
        }
    }
}
