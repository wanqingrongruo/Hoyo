//
//  RNUIView+Expand.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/13.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


/*
 UIView的一些扩展方法
 */

import Foundation
import UIKit

extension UIView{
    
    /**
     给UIView及其子类剪切圆角
     
     - parameter ActionView:        准备操作的View
     - parameter byRoundingCorners: 剪切哪几个角--[UIRectCorner.TopLeft,UIRectCorner.TopRight,UIRectCorner.BottomLeft,UIRectCorner.BottomRight]
     - parameter cornerRadii:       剪切的半径
     */
    func clipCornerRadiusForView(_ ActionView: UIView, RoundingCorners: UIRectCorner, Radii: CGSize) -> Void {
        
        let maskPath = UIBezierPath(roundedRect:ActionView.bounds, byRoundingCorners: RoundingCorners, cornerRadii: Radii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = ActionView.bounds
        maskLayer.path = maskPath.cgPath
        ActionView.layer.mask = maskLayer
    }
}
      
