//
//  TouchView.swift
//  PriceAggregator123
//
//  Created by student on 8/17/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

protocol TouchViewDelegate {
    func touchView(view: TouchView)
}

class TouchView: UIView {
    var delegate: TouchViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchView(view: self)
    }
}
