//
//  RNScanResultTableViewCell02.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNScanResultTableViewCell02Delegate {
    
    func addFilterSettingRecord(_ count: Int, index: IndexPath)
}

class RNScanResultTableViewCell02: UITableViewCell {

    var delegate: RNScanResultTableViewCell02Delegate?
    
    var recordCount = 0
    
     var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    // 增加
    @IBAction func addAction(_ sender: UIButton) {
        
        recordCount  = recordCount + 1
        self.delegate?.addFilterSettingRecord(recordCount, index: indexPath!)
    }
}
