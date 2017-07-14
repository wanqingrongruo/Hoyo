//
//  RNMultiFunctionLabel.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/18.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import Foundation
import UIKit

class RNMultiFunctionLabel: UILabel {
    
    enum TapGestureAction {
        case dailPhone
        case other
    }
    
    var isOpenTapGesture: Bool = false // 是否打开点击手势 -- default: false
    var isOpenLongGesture: Bool = true // 是否打开长按手势 -- default: true
    
    var isSkip = false  //  与 isOpenTapGesture 不能同时为 true
    var skipEvent: (() -> ())? // 跳转事件
    
    var isOpenHightLightForKeyword: Bool = false // 是否打开关键词高亮显示
    var keyword: String? = nil // 关键词
    
    var tapAction: TapGestureAction = .dailPhone // 点击手势行为
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isOpenTapGesture {
            self.addTapGesture()
        }
        
        if isOpenLongGesture {
            self.addLongPressGesture()
        }
        
        if isOpenHightLightForKeyword {
            
            guard let k = keyword else {
                return
            }
        
            guard let t = text else {
                return
            }
            
            let attr = NSMutableAttributedString(string: t)
            let str = NSString(string: t)
            let theRange = str.range(of: k)
            attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: theRange)
            self.attributedText = attr
            
            
        }
        
        if isSkip {
            skipAction()
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if isOpenTapGesture {
            self.addTapGesture()
        }
        
        if isOpenLongGesture {
            self.addLongPressGesture()
        }
        
        if isOpenHightLightForKeyword {
            
            guard let k = keyword else {
                return
            }
            
            guard let t = text else {
                return
            }
            
            let attr = NSMutableAttributedString(string: t)
            let str = NSString(string: t)
            let theRange = str.range(of: k)
            attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: theRange)
            self.attributedText = attr
            
        }
        
        if isSkip {
            skipAction()
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copyText(_:)){
            return true
        }else{
            return false
        }
        
    }
    
    override func copy(_ sender: Any?) {
        let pastBoard = UIPasteboard.general
        pastBoard.string = self.text
    }
    
    func copyText(_ sender: Any?){
        let pastBoard = UIPasteboard.general
        pastBoard.string = self.text
    }
}

//MARK: - private methods

extension RNMultiFunctionLabel {
    
    func addLongPressGesture() {
        
        self.isUserInteractionEnabled = true
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(gesture:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
    func longPressAction(gesture: UILongPressGestureRecognizer){
        
        if gesture.state == .began{
            
            self.becomeFirstResponder()
            
            let copyItem = UIMenuItem(title: "复制", action: #selector(copyText(_:)))
            let menuVC = UIMenuController.shared
            menuVC.menuItems = [copyItem]
            if menuVC.isMenuVisible {
                return
            }
            menuVC.setTargetRect(bounds, in: self)
            menuVC.setMenuVisible(true, animated: true)
        }
        
    }
    
    func addTapGesture() {
        self.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGetstureAction(_:)))
        self.addGestureRecognizer(tapGesture)
        
    }
    
    func tapGetstureAction(_ gesture: UITapGestureRecognizer) {
        
        
        switch tapAction {
        case .dailPhone:
            guard let title = self.text else{
                return
            }
            
            let telephoneNum = "telprompt://\(title)"
            guard let tel = URL(string: telephoneNum) else{
                return
            }
            UIApplication.shared.openURL(tel)
            
        default:
            break
        }
        
        
    }
    
    func skipAction() {
        self.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(skipGetstureAction(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    
    func skipGetstureAction(_ gesture: UITapGestureRecognizer) {
        
        if let skip = skipEvent {
            skip()
        }
        
    }

}
