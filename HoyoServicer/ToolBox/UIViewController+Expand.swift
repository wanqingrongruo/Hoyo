


//
//  UIViewController+extense.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 30/3/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension UIViewController
{

    func setNavigationItem(_ title:String,selector:Selector,isRight:Bool)
    {
        var item:UIBarButtonItem!
        
        if title.hasSuffix("png") {
            item = UIBarButtonItem(image: UIImage(named: title), style: .plain, target: self, action: selector)
        }
        else {
            item = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
            
        }
        
item.tintColor = UIColor.white
        
        if isRight {
            self.navigationItem.rightBarButtonItem = item
        }
        else {
            self.navigationItem.leftBarButtonItem = item
        }
        
        
    }
    func doRight(){
        
    }
    
    func doBack(){
        print("doBack")
        if(self.navigationController?.viewControllers.count>1)
        {
            _ = self.navigationController?.popToRootViewController(animated: true)
            
            
        }
        else{
            
            self.dismiss(animated: true, completion: nil)
        }
    }


}
