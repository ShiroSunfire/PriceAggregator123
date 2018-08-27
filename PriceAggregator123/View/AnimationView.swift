//
//  AnimatedView.swift
//  PriceAggregator123
//
//  Created by student on 8/16/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    
    var isFliped = false
    private var doubleSidedLayer:CATransformLayer?
    var lastDir:Direction!
    var topLayer = CALayer()
    var bottomLayer = CALayer()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defInit()
    }
    
    init (frame:CGRect, frontImage:UIImage){
        super.init(frame: frame)
        defInit()
        topLayer.contents = frontImage.cgImage
        topLayer.contentsGravity = kCAGravityResizeAspect
        
    }
    
    func defInit(){
        self.layer.isDoubleSided = true
        self.layer.backgroundColor = UIColor.white.cgColor
        
        doubleSidedLayer = CATransformLayer(layer: self.layer)
        doubleSidedLayer?.position = self.center
        doubleSidedLayer?.frame = self.frame
        doubleSidedLayer?.backgroundColor = UIColor.white.cgColor
        
        
        
        topLayer.frame = (doubleSidedLayer?.bounds)!
        topLayer.backgroundColor = UIColor.white.cgColor
        topLayer.zPosition = 2
        topLayer.isDoubleSided = false
        
        bottomLayer.frame = (doubleSidedLayer?.bounds)!
        bottomLayer.backgroundColor = UIColor.white.cgColor
        bottomLayer.zPosition = 1
        bottomLayer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
        var perspective = CATransform3DIdentity
        perspective.m34 = 1.0 / -500
        doubleSidedLayer?.transform = perspective
        doubleSidedLayer?.addSublayer(topLayer)
        doubleSidedLayer?.addSublayer(bottomLayer)
        
        self.layer.addSublayer(doubleSidedLayer!)
    }
    
    enum Direction{
        case left
        case right
    }
    
   
    
    func flip(to direction:Direction, with image:UIImage){
        doubleSidedLayer?.sublayerTransform = CATransform3DMakeRotation(0, 0, 1, 0)
        var perspective = CATransform3DIdentity
        perspective.m34 = 1.0 / -500
        doubleSidedLayer?.transform = perspective

        if lastDir != nil{
                let temp = bottomLayer.contents
                bottomLayer.contents = image.cgImage
                topLayer.contents = temp

        }else{
            bottomLayer.contents = image.cgImage
        }

        bottomLayer.contentsGravity = kCAGravityResizeAspect
        topLayer.contentsGravity = kCAGravityResizeAspect
        
        doubleSidedLayer?.sublayerTransform = CATransform3DMakeRotation(.pi, 0, 1, 0)
        lastDir = direction
        isFliped = !isFliped
    }
}



extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
