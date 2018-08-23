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

    private let cellId = "DescribingCell"
    private var itemId:Int!
    var item:Item!
    private var gjson = GetJSON()
    private var scaledImageView:AnimationView!{
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

    private var refresh: RefreshImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.item.thumbnailImage = [UIImage]()
        itemName.textAlignment = .center
        itemImageCollection.delegate = self
        itemImageCollection.dataSource = self
        itemImageCollection.isPagingEnabled = true
        imagePageControl.addTarget(self, action: #selector(pageControlTapHandler), for: .touchUpInside)
        priceLabel.text = ""
        self.setDataToView()
        loadDataAboutItem()
        
    }
    
    @IBAction private func addToBasketPressed(_ sender: UIButton) {
        DBManager().saveData(database: .basket, item: item)
        let alert = UIAlertController(title: NSLocalizedString("Item added to basket" ,comment: ""), message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    @IBAction private func addToFavoritesPressed(_ sender: UIButton) {
        
        DBManager().saveData(database: .favorites, item: item)
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

   private func loadDataAboutItem(){
        let isNil = item.thumbnailImage == nil
        let opCompleted = {
            self.addImagesToCellImages()
        }
    gjson.getItems(with: Int(item.id!), imageLoaded: imageLoaded(_:), operationCompleted: opCompleted, isNil: isNil)
        
    }

    private func imageLoaded(_ image :UIImage){
        if !(self.item.thumbnailImage?.contains(image))!{
            item.thumbnailImage?.append(image)
        }
        addImagesToCellImages()
        refresh?.removeFromSuperview()
    }

    
    private func setDataToView(){
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
    
    private func addImagesToCellImages(){
        if item.thumbnailImage != nil{
            DispatchQueue.main.async {
                self.itemImageCollection.reloadData()
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
    
    private func addTapGestureForScaledImage(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(scaledImageTapHandler(sender:)))
        scaledImageView?.addGestureRecognizer(tap)
    }
    
    private func addSwipeGestureForScaledImage(){
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(scaledImageSwipeHandler(sender: )))
        swipeGestureLeft.direction = .left
        scaledImageView?.addGestureRecognizer(swipeGestureLeft)
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(scaledImageSwipeHandler(sender: )))
        swipeGestureRight.direction = .right
        scaledImageView?.addGestureRecognizer(swipeGestureRight)
    }
    
    
    
    @objc private func scaledImageTapHandler(sender: UITapGestureRecognizer){
        
        UIView.animate(withDuration: 1.0, animations: {
            self.scaledImageView.alpha = 0.0
        }) { (_) in
            sender.view?.removeFromSuperview()
            self.scaledImageView = nil
        }
    }
    
    @objc private func scaledImageSwipeHandler(sender:  UISwipeGestureRecognizer){
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

