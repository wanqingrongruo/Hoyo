//
//  RNCarInfoTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/12.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNCarInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ model: RNCarInfoModel, index: IndexPath){
        
        titleLabel.text = model.title
        contentLabel.text = model.content
    }
    
}
