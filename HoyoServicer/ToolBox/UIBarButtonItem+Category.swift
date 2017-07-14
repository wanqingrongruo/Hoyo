//
//  UIBarButtonItem+Category.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/4/27.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

//MARK: -UIBarButtonItem扩展方法
extension UIBarButtonItem{
    
    /**
     <#Description#>
     
     - parameter imageName: 图片名称，可为nil
     - parameter target:    响应者
     - parameter action:    事件
     
     - returns:UIBarButtonItem
     */
    class func  createBarButtonItem(_ imageName:String?,target:AnyObject?,action:Selector) -> UIBarButtonItem{
        
        let btn = UIButton()
        if imageName != nil {
            btn.setImage(UIImage(named: imageName!), for: UIControlState())
        }
        
       // btn.frame = CGRect(x: 0, y: 0, width: 20, height: 30)
        btn.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        btn.sizeToFit()
        
        return UIBarButtonItem(customView: btn)
        
    }
    
    class func createBarButtonItem02(_ imageName:String?,target:AnyObject?,action:Selector) -> UIBarButtonItem{
        
        let btn = UIButton()
        if imageName != nil {
            btn.setImage(UIImage(named: imageName!), for: UIControlState())
        }
        
        btn.frame = CGRect(x: 0, y: 0, width: 10, height: 30)
        btn.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        //btn.sizeToFit()
        
        return UIBarButtonItem(customView: btn)
        
    }
    
}
