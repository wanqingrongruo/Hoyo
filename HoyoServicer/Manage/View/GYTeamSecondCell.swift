//
//  GYTeamSecondCell.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class GYTeamSecondCell: UITableViewCell {

    @IBOutlet weak var grabNumberLb: UILabel!
    @IBOutlet weak var groupMaxNumber: UILabel!
    
    
    func reloadUI(_ strArr:[String]) {
        grabNumberLb.text = strArr[0] + "  " + strArr[1]
        groupMaxNumber.text = strArr[2] + "  " + strArr[3]
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
