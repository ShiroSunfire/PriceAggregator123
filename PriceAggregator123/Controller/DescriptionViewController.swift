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
    
    private let apiKey = "jx9ztwc42y6mfvvhfa4y87hk"
    private let cellId = "DescribingCell"
    private var itemId:Int!
    var item:Item = Item()
    private var gjson = GetJSON()
    var scaledImageView:AnimationView!{
        didSet{
            addSwipeGestureForScaledImage()
            addTapGestureForScaledImage()
        }
    }
    
    @IBOutlet private weak var itemImageCollection: UICollectionView!
    @IBOutlet private weak var imagePageControl: UIPageControl!
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var descriptionText: UITextView!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var addToBasketButton: UIButton!
    @IBOutlet private weak var addToFavoritesButton: UIButton!

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
        unparseDataAboutItem()
    }
    
    @IBAction private func addToBasketPressed(_ sender: UIButton) {
        let db = DBManager()
        db.saveData(database: .basket, item: item)
        let alert = UIAlertController(title: NSLocalizedString("Item added to basket" ,comment: ""), message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    @IBAction private func addToFavoritesPressed(_ sender: UIButton) {
        let db = DBManager()
        db.saveData(database: .favorites, item: item)
        let alert = UIAlertController(title: NSLocalizedString("Item added to favorite", comment: ""), message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func pageControlTapHandler(sender: UIPageControl){
        let index = IndexPath(item: sender.currentPage, section: 0)
        print(sender.currentPage)
        itemImageCollection.scrollToItem(at: index, at: [], animated: true)
    }
    
    func getItemFromURL(_ json: JSON) {
        if json["imageEntities"].array != nil{
            if self.item.thumbnailImage != nil{
                for index in 0...json["imageEntities"].count - 1{
                    let element = json["imageEntities"][index]["largeImage"].string!
                    self.downloadImage(with: element, to: self.item)
                }
            }
        } else {
            self.downloadImage(with: json["largeImage"].string!, to: self.item)
        }
        self.addImagesToCellImages()
    }
    
    func unparseDataAboutItem(){
        let urlString = "https://api.walmartlabs.com/v1/items/\(item.id!)?apiKey=\(apiKey)&lsPublisherId=&format=json"
        gjson.getItems(with: URL(string: urlString), completion: getItemFromURL(_:))
    }

    func downloadImage(with url:String,to item:Item) {
        guard let url = URL(string: url) else { return }
        gjson.downloadImage(with: url, i: 0) { (image, index) in
            item.thumbnailImage?.append(image)
            self.addImagesToCellImages()
            self.refresh?.removeFromSuperview()
        }
    }
    
    func setDataToView(){
        if let price = item.price{
            let priceLabelText = NSLocalizedString("Price: ", comment: "")
            priceLabel.text! = priceLabelText + String(price) + "$"
        }else {priceLabel.text! =  NSLocalizedString("Price not Available", comment: "")}
        
        if let name = item.name{
            itemName.text = name
        }else{ itemName.text = NSLocalizedString("NO NAME", comment: "") }
        
        if let description = item.descriptionItem{
            descriptionText.text = description
        }else { descriptionText.text = NSLocalizedString("no description", comment: "")}
        
        
        addToFavoritesButton.setTitle(NSLocalizedString("To Favorites", comment: ""), for: .normal)
        addToBasketButton.setTitle(NSLocalizedString("To Basket", comment: ""), for: .normal)
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
                }
            }
            
        } else if sender.direction == .left{
            if imageIndex <   (item.thumbnailImage?.count)! - 1{
                if (sender.view as? AnimationView) != nil{
                    scaledImageView.flip(to: AnimationView.Direction.left, with: item.thumbnailImage![imageIndex + 1])
                }
            }
        }
    }
}

