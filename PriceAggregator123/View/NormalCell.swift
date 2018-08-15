//
//  NormalCell.swift
//  PriceAggregator
//
//  Created by student on 8/13/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class NormalCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func buyButtonTapped(_ sender: Any) {
        
    }
}
