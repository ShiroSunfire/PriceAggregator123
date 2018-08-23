//
//  InfoPlace.swift
//  PriceAggregator123
//
//  Created by student on 8/21/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class InfoPlace: UIView {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    
    func setValues(name: String, address: String, phoneNumber: String) {
        nameLabel.text = name
        addressLabel.text = address
        phoneNumberLabel.text = phoneNumber
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
