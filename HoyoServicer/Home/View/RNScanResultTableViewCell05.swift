//
//  RNScanResultTableViewCell05.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNScanResultTableViewCell05Delegate {
    
    func confirmAndSave()
}

class RNScanResultTableViewCell05: UITableViewCell {
    
    var delegate:RNScanResultTableViewCell05Delegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // 确定并保存
    @IBAction func saveAction(_ sender: UIButton) {
        
        self.delegate?.confirmAndSave()
    }
}
