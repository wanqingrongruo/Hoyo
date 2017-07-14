//
//  RNFinacialManagerCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/6/7.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNFinacialManagerCell: UITableViewCell {
    
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadUI(_ model:AccountDetailModel) {
        
        if let No = model.payId, No != "" {
            orderIdLabel.text = model.payId
        }else{
            orderIdLabel.text = "提现"
        }
        
        //  获取类型 0: 全部, 1: 收入, 2: 提现, 3:扣款
        if let way = model.way, way == "2", let money = model.money{
           moneyLabel.text = "-" + money
        }else{
           moneyLabel.text = model.money
        }
        timeLabel.text = model.createTime
    }
    
}
