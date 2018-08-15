//
//  RefreshImageView.swift
//  PriceAggregator
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class RefreshImageView: UIImageView {

    init(center: CGPoint) {
        super.init(image: #imageLiteral(resourceName: "refresh.png"))
        self.center = CGPoint(x: center.x, y: center.y - 50)
        animation()
    }
    
    func animation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = 0.0
        anim.toValue = Double.pi*2
        anim.duration = 5
        anim.repeatCount = 100
        self.layer.add(anim, forKey: "transform.rotation")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
