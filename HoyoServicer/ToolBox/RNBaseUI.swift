//
//  RNBaseUI.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/18.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//  容若的简书地址:http://www.jianshu.com/users/274775e3d56d/latest_articles
//  容若的新浪微博:http://weibo.com/u/2946516927?refer_flag=1001030102_&is_hot=1


import UIKit

class RNBaseUI: NSObject {
    
    /**
     创建label
     
     - parameter title:      标题
     - parameter titleColor: 标题颜色
     - parameter font:       字体
     - parameter alignment:  对齐方式
     
     - returns: label
     */
    class func createLabel(_ title: String,titleColor: UIColor, font: CGFloat, alignment: NSTextAlignment) -> UILabel{
        let label = UILabel()
        label.text = title
        label.textColor = titleColor
        label.font = UIFont.systemFont(ofSize: font)
        label.textAlignment = alignment
        
        return label
    }
    
    /**
     创建button
     
     - parameter title:      标题
     - parameter titleColor: 标题颜色
     - parameter font:       字体
     - parameter alignment:  对齐方式
     - parameter target:     target
     - parameter sel:        sel
     
     - returns: button
     */
    class func createButton(_ title: String, titleColor: UIColor, font: CGFloat, alignment: NSTextAlignment, target: AnyObject?, sel: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(titleColor, for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: font)
        button.titleLabel?.textAlignment = alignment
        button.addTarget(target, action: sel, for: UIControlEvents.touchUpInside)
        
        return button
    }
    
    /**
     创建textField
     
     - parameter placeholder:     占位符
     - parameter keyboardType:    键盘类型
     - parameter clearButtonMode: clearButtonMode
     - parameter returnKeyType:   回车键类型
     - parameter delegate:        代理
     
     - returns: textField
     */
    class func createTextField(_ placeholder: String?, keyboardType: UIKeyboardType, clearButtonMode: UITextFieldViewMode?, returnKeyType: UIReturnKeyType?, delegate: UITextFieldDelegate?) -> UITextField{
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        
        if clearButtonMode != nil {
             textField.clearButtonMode = clearButtonMode!
            
        }
        if returnKeyType != nil {
             textField.returnKeyType = returnKeyType!
           
        }
        if delegate != nil {
            textField.delegate = delegate!
        }
        
        
        return textField
    }
    
    
    /**
     创建textView
     
     - parameter keyboardType:    键盘类型
     - parameter returnKeyType:   回车键类型

     - returns: textView
     */
    class func creatTextView(_ keyboardType: UIKeyboardType, returnKeyType: UIReturnKeyType?) -> UITextView{
        let textView = UITextView()
        textView.keyboardType = keyboardType
        
        if returnKeyType != nil {
            textView.returnKeyType = returnKeyType!
            
        }

        return textView
    }
    
    /**
     创建imageView
     
     - parameter image:           图片
     - parameter backgroundColor: 背景
     
     - returns: imageView
     */
    class func createImageView(_ image: String?,backgroundColor: UIColor?) -> UIImageView{
        let imageView = UIImageView()
        
        if image != nil {
            imageView.image = UIImage(named: image!)
        }
        
        if backgroundColor != nil {
            imageView.backgroundColor = backgroundColor!
        }
        
        return imageView
    }

}
