//
//  NormalCell.swift
//  PriceAggregator
//
//  Created by student on 8/13/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

protocol NormalCellDelegate {
    func buyButtonTapped(db: String)
    func favoriteButtonTapped(db: String)
}

class NormalCell: UICollectionViewCell {

    var item:Item?
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    var delegate: NormalCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func buyButtonTapped(_ sender: Any) {
        delegate?.buyButtonTapped(db: "Basket")
        let db = DBManager()
        db.saveData(DB: "Basket", item: item!)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        delegate?.favoriteButtonTapped(db: "Favourites")
        let db = DBManager()
        db.saveData(DB: "Favourites", item: item!)
    }
}
