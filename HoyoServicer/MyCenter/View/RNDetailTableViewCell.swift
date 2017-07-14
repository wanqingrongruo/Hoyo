//
//  RNDetailTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/12.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageVIew: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //显示数据
    func config(_ model: RNMYCenterModel, index: IndexPath){
        
        logoImageVIew.image = UIImage(named: model.logo!)
        descLabel.text = model.desc
    }
    
}
