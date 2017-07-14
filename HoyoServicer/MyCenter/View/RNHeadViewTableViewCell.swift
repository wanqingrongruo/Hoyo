//
//  RNHeadViewTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/12.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNHeadViewTableViewCell: UITableViewCell {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
