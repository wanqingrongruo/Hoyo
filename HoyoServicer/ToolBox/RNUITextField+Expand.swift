//
//  RNUITextField+Expand.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/13.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


import Foundation
import UIKit

extension UITextField{
    

    
    /**
     校验数字的数字(例如钱金额),保留小数点几位----方法放在func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool 这个代理方法里
     
     - parameter text:              需要处理的字符串
     - parameter range:             正在输入为的范围
     - parameter replacementString: 正在输入的字符
     - parameter remian:            保留小数点后几位
     
     - returns: 输入符合要求true,反之false
     */
    func moneyFormatCheck(_ text: String, range: NSRange, replacementString: String, remian: Int) -> Bool {
        
        //限制输入框只能输入数字(最多两位小数)
        let newString = (text as NSString).replacingCharacters(in: range, with: replacementString)
        let expression = "^[0-9]*((\\.)[0-9]{0,\(remian)})?$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        return numberOfMatches != 0

    }
    
    /**
     限制输入框只能输入数字
     
     - parameter text:              需要处理的字符串
     - parameter range:             正在输入为的范围
     - parameter replacementString: 正在输入的字符
     
     - returns: 输入符合要求true,反之false
     */
    func digitFormatCheck(_ text: String, range: NSRange, replacementString: String) -> Bool{
        
        //限制输入框只能输入数字
       // let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: replacementString)
        let newString = (text as NSString).replacingCharacters(in: range, with: replacementString)
        let expression = "^[0-9]*$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        return numberOfMatches != 0
    }
    
    /**
     手机号码校验
     
     - parameter text:              需要处理的字符串
     - parameter range:             正在输入为的范围
     - parameter replacementString: 正在输入的字符
     
     - returns: 输入符合要求true,反之false
     */
    func phoneFormatCheck(_ text: String, range: NSRange, replacementString: String) -> Bool {
        
        let newString = (text as NSString).replacingCharacters(in: range, with: replacementString)
        let expression = "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        return numberOfMatches != 0
    }
}
