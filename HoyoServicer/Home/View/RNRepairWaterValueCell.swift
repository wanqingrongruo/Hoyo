//
//  RNRepairWaterValueCell.swift
//  HoyoServicer
//
//  Created by 郑文祥 on 2017/6/16.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNRepairWaterValueCellDelegate {
    func linkBluetooth()
}

class RNRepairWaterValueCell: UITableViewCell {

    var delegate: RNRepairWaterValueCellDelegate?
    @IBAction func pairAction(_ sender: UIButton) {
        
        delegate?.linkBluetooth()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
