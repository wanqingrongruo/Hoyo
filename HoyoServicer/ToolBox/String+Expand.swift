//
//  String+Expand.swift
//  OznerServer
//
//  Created by 赵兵 on 16/2/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
// string 扩展，一些常用字符串处理等等
extension String{
    //md5加密
    //判断字符串是否全是数字
    var isAllNumber:Bool{
        let pred = NSPredicate(format: "SELF MATCHES %@", "^[0-9]*$")
        if pred.evaluate(with: self) {
            return true
        }
        return false
    }
    
    func phoneFormatCheck() -> Bool {
        
        let expression = "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: self, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (self as NSString).length))
        return numberOfMatches != 0
    }

    
}
