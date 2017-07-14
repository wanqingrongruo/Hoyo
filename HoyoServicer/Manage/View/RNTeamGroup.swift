//
//  RNTeamGroup.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/17.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNTeamGroup: UITableViewCell {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var memberDetail: TeamMembers?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 23
        
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 10.5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ memberDetail: TeamMembers) {
        
        self.memberDetail = memberDetail

        if let headString = memberDetail.headimageurl, let headUrl = URL(string: headString) {
            headImageView.sd_setImage(with: headUrl, placeholderImage: UIImage(named: "DefaultHeadImg"))
        }else{
            headImageView.image = UIImage(named: "DefaultHeadImg")
        }
        
        if let nickName = memberDetail.nickname {
            nameLabel.text = nickName
        }else{
            nameLabel.text = "佚名"
        }
        
        if let id = memberDetail.userid {
            IDLabel.text = "ID:\(String(describing: id))"
        }else{
            IDLabel.text = "ID:无"
        }
        
        if let title = memberDetail.title {
            
            if title == "" {
                titleLabel.text = "暂未分类"
            }else{
                titleLabel.text = title
            }
           
        }else{
            titleLabel.text = "暂未分类"
        }
    }

    
}
