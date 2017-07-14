//
//  RNSimpleTrasition.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/2/17.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNSimpleTrasition: NSObject, UIViewControllerAnimatedTransitioning{

    // 定义转场动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let fromView = fromVC?.view
        
        let toVC = transitionContext.viewController(forKey: .to)
        let toView = toVC?.view
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView!)
        containerView.addSubview(toView!)
        
        // 转场动画
        toView?.alpha = 0.05
        UIView.animate(withDuration: 0.3, animations: {
            fromView?.alpha = 0.05
            
            
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, animations: {
                toView?.alpha = 1
                
            }, completion: { finished in
                
                // 通知完成转场
                transitionContext.completeTransition(true)
            })
            
        })

    }
}
