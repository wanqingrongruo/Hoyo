//
//  MyEvaluatCell.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/8.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class MyEvaluatCell: UITableViewCell {
//头像
    @IBOutlet weak var headImage: UIImageView!
  
    //评价时间加内容
    @IBOutlet weak var remark: UILabel!
    
 @IBOutlet weak var orderid: UILabel!
    
    
    @IBOutlet weak var score1: UIImageView!
    
    @IBOutlet weak var score2: UIImageView!
    
    @IBOutlet weak var score3: UIImageView!
    
    @IBOutlet weak var score4: UIImageView!
    
    @IBOutlet weak var score5: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
