//
//  RNPatButtonTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/9/27.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNPatButtonTableViewCellDelegate {
    
   // 支付
    func gotoPay()
}


class RNPatButtonTableViewCell: UITableViewCell {
    
    var delegate: RNPatButtonTableViewCellDelegate? // 代理
    @IBOutlet weak var payButton: UIButton! // 支付按钮

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 立即支付
    @IBAction func payAction(_ sender: UIButton) {
     
        delegate?.gotoPay()
    }
    
}
