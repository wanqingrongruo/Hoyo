//
//  SubmitBtn.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 21/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
protocol SubmitBtnDelegate {
    func submitToServer()
}
class SubmitBtn: UITableViewCell {
    var delegate:SubmitBtnDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func submit(_ sender: AnyObject) {
        delegate?.submitToServer()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
