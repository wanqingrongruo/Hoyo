//
//  RNOtherFeeTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/31.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit


class RNOtherFeeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        
    }
    
    func configCell(_ title: String, money: Double, index: IndexPath){
        
        titleLabel.text = title
        moneyLabel.text = "\(money)"
    }
    
}

