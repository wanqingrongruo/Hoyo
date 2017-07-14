//
//  RNTeamGroupDetail.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/17.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNTeamGroupDetail: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    
    @IBOutlet weak var whichTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: RNMultiFunctionLabel!
    @IBOutlet weak var dailButton: UIButton!
    @IBAction func dailNumber(_ sender: UIButton) {
        
        guard let title = groupDetail?.mobile else{
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "号码格式不正确")
            return
        }
        
        let telephoneNum = "telprompt://\(title)"
        guard let tel = URL(string: telephoneNum) else{
            return
        }
        UIApplication.shared.openURL(tel)

    }
    
    
    var groupDetail: GroupDetail?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 10.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(model: GroupDetail, flag: Int) {
        
        self.groupDetail = model
        
        if flag == 0 {
            whichTitleLabel.text = "团队负责人:"
        }else{
            whichTitleLabel.text = "小组负责人:"
        }
        
        groupNameLabel.text = model.groupName
        
        if let ID = model.groupId {
            IDLabel.text = "ID:" + ID
        }else{
            IDLabel.text = "ID:" + "无"
        }
        
        
        nameLabel.text = model.leaderName
        
        if let title = model.title, title != ""{
            titleLabel.text = model.title
        }else{
            titleLabel.text = "暂未分类"
        }
        
        
        if let mobile = model.mobile {
            var m = mobile
            if m.characters.count > 7{
                
                m.insert("-", at: m.index(m.startIndex, offsetBy: 3))
                m.insert("-", at: m.index(m.startIndex, offsetBy: 8))
                
            }
            
            phoneLabel.text = m
        }else{
            phoneLabel.text = model.mobile
        }

        
    }
    
}
