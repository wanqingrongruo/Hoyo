//
//  RNScanResultTableViewCell04.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNScanResultTableViewCell04Delegate {
    
    func addServiceRecord(_ index: IndexPath)
}

class RNScanResultTableViewCell04: UITableViewCell {
    
    var delegate: RNScanResultTableViewCell04Delegate?
    
     var indexPath:IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        
        self.delegate?.addServiceRecord(indexPath!)
    }
}
