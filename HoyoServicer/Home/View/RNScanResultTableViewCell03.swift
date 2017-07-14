//
//  RNScanResultTableViewCell03.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNScanResultTableViewCell03Delegate {
    
    func addChangeFilterRecord(_ index: IndexPath)
}
class RNScanResultTableViewCell03: UITableViewCell {
    
    var delegate: RNScanResultTableViewCell03Delegate?
    
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
        
        self.delegate?.addChangeFilterRecord(indexPath!)
    }
}
