//
//  CustomPush.swift
//  PriceAggregator123
//
//  Created by student on 8/17/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class DefaultPresent: NSObject, UIViewControllerAnimatedTransitioning{
    var durationExpanding = 0.0
    let durationClosing = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    
    init(duration:Double = 0.75) {
        durationExpanding = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if presenting{
            return durationExpanding
        }else{
            return durationClosing
        }
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
}


class CustomPush: DefaultPresent{
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to), let descriptionView = presenting ? toView: transitionContext.view(forKey: .from) else {
            return
        }
        let initialFrame = presenting ? originFrame : descriptionView.frame
        let finalFrame = presenting ? descriptionView.frame : originFrame
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
        if presenting {
            descriptionView.transform = scaleTransform
            descriptionView.center = CGPoint( x: initialFrame.midX, y: initialFrame.midY)
            descriptionView.clipsToBounds = true
        }
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: descriptionView)
        if presenting {
            UIView.animate(withDuration: durationExpanding, delay:0.0,
                           usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                animations: {
                    descriptionView.transform = CGAffineTransform.identity
                    descriptionView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            },
                completion:{_ in
                    transitionContext.completeTransition(true)
            }
            )
        }
    }
}

class CustomPop: DefaultPresent {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from)
            else {
                return
        }
        
        if  let toViewController = transitionContext.viewController(forKey: .to) {
            transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        }
        
        
        UIView.animate(withDuration: self.durationClosing, animations: {
            fromViewController.view.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}




    
    
    

