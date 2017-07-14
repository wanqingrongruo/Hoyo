//
//  RNTeamGroupListTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/17.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNTeamGroupListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: RNMultiFunctionLabel!
    @IBOutlet weak var IDLabel: RNMultiFunctionLabel!
    
    var groupDetail: GroupDetail? = nil
    
    var isOpenHighLight: Bool = false
    var keyword: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ groupDetail: GroupDetail) {
        
        self.groupDetail = groupDetail
        
        nameLabel.text = groupDetail.groupName
        
        if let id = groupDetail.groupId {
           IDLabel.text = "ID:\(String(describing: id))"
        }else{
           IDLabel.text = "ID:无"
        }
        
        if isOpenHighLight {
            nameLabel.attributedText = hightLight(text: nameLabel.text)
            IDLabel.attributedText = hightLight(text: IDLabel.text)
        }
        
       
    }
    
    func hightLight(text: String?) -> NSAttributedString?{
        
        guard let k = keyword else {
            return nil
        }
        
        guard let t = text else {
            return nil
        }
        
        let attr = NSMutableAttributedString(string: t)
        let str = NSString(string: t)
        let theRange = str.range(of: k)
        attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: theRange)
        return attr

    }
    
}
