//
//  NormalCell.swift
//  PriceAggregator
//
//  Created by student on 8/13/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class NormalCell: UICollectionViewCell {

    var item:Item?
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func buyButtonTapped(_ sender: Any) {
        let db = DBManager()
        db.saveData(DB: "Favourites", item: item!)
        let itemm = db.loadData(DB: "Favourites")
        print(itemm.count)
        print(itemm)
        db.removeData(DB: "Favourites", item: item!)
        print("AFTER DELETE")
        let itemmm = db.loadData(DB: "Favourites")
        print(itemmm.count)
    }
}
