//
//  RNToolBarView.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

open class RNToolBarView: UIView {

    typealias CustomClosures = (_ titleLabel: UILabel, _ cancleBtn: UIButton, _ doneBtn: UIButton) -> Void
    typealias BtnAction = () -> Void
    
    internal var title = "请选择" {
        didSet{
            titleLabel.text = title
        }
    }
    
    // 'done' and 'cancel' button event declare
    internal var doneAction: BtnAction?
    internal var cancelAction: BtnAction?
    
    // seperator line effect between toolbar and the content view(this is tableView here now)
    fileprivate lazy var contentView: UIView = {
        
        let content = UIView()
        content.backgroundColor = UIColor.white
        return content
    }()
    
    
    // titleLabel: tell user what is selected
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    // cancel button
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: UIControlState())
        button.setTitleColor(UIColor.black, for: UIControlState())
        return button
    }()
    
    // done button
    fileprivate lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("完成", for: UIControlState())
        button.setTitleColor(UIColor.black, for: UIControlState())
        return button
    }()
    
    
    // override init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let margin = 15.0
        let contentHeight = Double(bounds.size.height) - 2.0
        let contentWidth = Double(bounds.size.width)
        contentView.frame = CGRect(x: 0, y: 1.0, width: contentWidth, height: contentHeight-2)
        
        let btnWidth = contentHeight // 按钮宽高相等 == contentView height
        
        cancelButton.frame = CGRect(x: margin, y: 0.0, width: btnWidth, height: btnWidth)
        doneButton.frame = CGRect(x:  Double(bounds.size.width) - margin - btnWidth, y: 0.0, width: btnWidth, height: btnWidth)
        
        let titleLabelX = Double(cancelButton.frame.maxX) + margin
        let titleLableW = Double(bounds.size.width) - titleLabelX - margin - btnWidth - margin
        titleLabel.frame = CGRect(x: titleLabelX, y: 0.0, width: titleLableW, height: btnWidth)
    }
    
    
}

// MARK: - custom methods

extension RNToolBarView{
    
    fileprivate func commonInit(){
        
        backgroundColor = UIColor.lightText
        addSubview(contentView)
        
        // add button & titleLabel to contentView
        contentView.addSubview(cancelButton)
        contentView.addSubview(doneButton)
        contentView.addSubview(titleLabel)
        
        // 按钮事件
        cancelButton.addTarget(self, action: #selector(self.cancelBtnClick(_:)), for: UIControlEvents.touchUpInside)
        doneButton.addTarget(self, action: #selector(self.doneBtnClick(_:)), for: UIControlEvents.touchUpInside)
    }
    
    
}

// MARK: - event response

extension RNToolBarView{
    
    func doneBtnClick(_ sender: UIButton){
        doneAction?()
    }
    
    func cancelBtnClick(_ sender: UIButton){
        cancelAction?()
    }
}
