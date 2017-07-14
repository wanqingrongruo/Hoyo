//
//  PersonInfoStateView.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/12.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class PersonInfoStateView: UIView {
    var useNameLable: UILabel?
    var timeLabel: UILabel?
    var stateLabel: UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化UI
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        backgroundColor = UIColor.white
        addSubview(userName)
        addSubview(timeLb)
        addSubview(stateLb)
    }
    
    
    fileprivate lazy var userName: UILabel = {
        let lb = UILabel()
        lb.text = "用户名"
        lb.frame = CGRect(x: 15, y: 20, width: 100, height: 30)
        return lb
    }()
    
    fileprivate lazy var timeLb: UILabel = {
        let lb = UILabel()
        lb.text = "申请时间"
        lb.frame = CGRect(x: 15, y: 70, width: 100, height: 30)
        return lb
    }()
    
    fileprivate lazy var stateLb: UILabel = {
        let lb = UILabel()
        lb.text = "审核状态"
        lb.frame = CGRect(x: 15, y: 120, width: 100, height: 30)
        return lb
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
