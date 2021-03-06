//
//  NormalCell.swift
//  PriceAggregator
//
//  Created by student on 8/13/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

@objc protocol NormalCellDelegate {
    @objc optional func buyButtonTapped(db: String, item: Item)
    @objc optional func favoriteButtonTapped(db: String, item: Item)
    @objc optional func deleteCell(cell: NormalCell)
}

import UIKit

class NormalCell: UICollectionViewCell {
    var pan: UIPanGestureRecognizer!
    var deleteLabel: UILabel!
    var buyLabel: UILabel!
    var item:Item?
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    var delegate: NormalCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        quantityLabel?.isHidden = true
    }
    
    @IBAction func buyButtonTapped(_ sender: Any) {
        delegate?.buyButtonTapped!(db: "Basket", item: item!)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        delegate?.favoriteButtonTapped!(db: "Favourites", item: item!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if pan != nil{
            if (pan.state == UIGestureRecognizerState.changed) {
                let p: CGPoint = pan.translation(in: self)
                let width = self.contentView.frame.width
                let height = self.contentView.frame.height
                self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height);
                self.deleteLabel.frame = CGRect(x: p.x - deleteLabel.frame.size.width-10, y: 0, width: 100, height: height)
                self.buyLabel.frame = CGRect(x: p.x + width + buyLabel.frame.size.width, y: 0, width: 100, height: height)
            }
        }
    }
    
    func addDeletePan(){
        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    
    private func commonInit(){
        self.contentView.backgroundColor = UIColor.white
        self.contentView.tintColor = UIColor.black
        self.backgroundColor = UIColor.red
        
        labelDescription.backgroundColor = UIColor.white
        
        deleteLabel = UILabel()
        deleteLabel.text = NSLocalizedString("delete", comment: "")
        deleteLabel.textColor = UIColor.white
        self.insertSubview(deleteLabel, belowSubview: self.contentView)
        
        buyLabel = UILabel()
        buyLabel.text = NSLocalizedString("delete", comment: "")
        buyLabel.textColor = UIColor.white
        self.insertSubview(buyLabel, belowSubview: self.contentView)
    }
    
    @objc func onPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizerState.began {
            
        } else if pan.state == UIGestureRecognizerState.changed {
            self.setNeedsLayout()
        } else {
            if abs(pan.velocity(in: self).x) > 500 {
                self.setNeedsLayout()
                self.layoutIfNeeded()
                delegate?.deleteCell!(cell: self)
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
    }
}

extension NormalCell: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    }
}

