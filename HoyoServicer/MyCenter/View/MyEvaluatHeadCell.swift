//
//  MyEvaluatHeadCell.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/8.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class MyEvaluatHeadCell: UITableViewCell {
    
    //已接单数
    @IBOutlet weak var alreadyGetLists: UILabel!
    //已完成数
    @IBOutlet weak var alreadyDidCount: UILabel!
    
    //top 当前综合评分多少
    @IBOutlet weak var evaluateTitle: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var score1: UIImageView!
    
    @IBOutlet weak var score2: UIImageView!
    
    @IBOutlet weak var score3: UIImageView!
    
    @IBOutlet weak var score4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var score5: UIImageView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
