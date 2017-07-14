//
//  SubmitCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 15/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit



protocol SubmitCellDelegate {
    
    // 选择用时
    func poptoSuperCon(_ label1:String)
    
    // 扫描
    func popAboutScanToSuperCon(_ whichLabel:String)
    
    // 上传照片
    func uploadPhoto(_ press: UITapGestureRecognizer)
    
    // 选择配件
    func popToSelectProductMaterial()
    
    // 刷新 tableView
    func reloadTableView()
    
    // 连接蓝牙
    func linkBluetooth()
}

class SubmitCell: UITableViewCell{
    
    var delegate: SubmitCellDelegate? // 代理
    
   // var payWay: String = "Money" //支付方式
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

