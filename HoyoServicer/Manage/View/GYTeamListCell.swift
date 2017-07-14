//
//  GYTeamListCell.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/3.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SDWebImage

class GYTeamListCell: UITableViewCell {
    
    @IBOutlet var nickNameLb: UILabel!
    @IBOutlet var memberState: UILabel!
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var titleLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /**
     加载控件数据
     */
    func reloadUIWithModel(_ model:TeamMembers,memScope:String)
    {
        nickNameLb.text = model.nickname
        if model.headimageurl! != "" {
            let urlStr = "http://wechat.hoyofuwu.com/" + model.headimageurl!
            iconImage.sd_setImage(with: URL(string: urlStr))
        }
        
        titleLable.text = model.Scope
        if model.MemberState == "70000" {
            memberState.text = "待审核"
        } else if model.MemberState == "70002" || model.MemberState == "70003"{
            memberState.text = "已拒绝"
        } else {
            memberState.text = ""
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
