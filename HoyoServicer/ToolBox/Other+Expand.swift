//
//  Other+Expand.swift
//  OznerServer
//
//  Created by 赵兵 on 16/3/5.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
/**
 判断是不是空或null
 */
func MSRIsNilOrNull(_ object: AnyObject?) -> Bool {
    return object == nil || object is NSNull
    
}
//-------------------检查手机号格式-------------------------
func checkTel(_ str:NSString)->Bool
{
    if (str.length != 11) {
        
        return false
    }
    let regex = "^\\d{11}$"
    let pred = NSPredicate(format: "SELF MATCHES %@",regex)
    
    let isMatch = pred.evaluate(with: str)
    if (!isMatch) {
        return false
    }
    return true
}
extension UINavigationBar{
    //黑底白字
    func loadBlackBgBar() {
        self.setBackgroundImage(UIImage(named: "blackImgOfNavBg"), for: UIBarMetrics.default)
        self.shadowImage =  UIImage(named: "blackImgOfNavBg") // shadowImage 就是那条 1px 的细线
        self.titleTextAttributes=[NSForegroundColorAttributeName:UIColor.white]
    }
    // 按钮和标题
//    func addBackAndTitle()
//    {
//        
//    }
    //
}
