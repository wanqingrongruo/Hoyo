//
//  RNVIPictureTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/11/1.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNVIPictureTableViewCell: UITableViewCell {

    @IBOutlet weak var viPictureImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ pic: String){
        
        if pic == "" {
            return
        }
        
        let url = URL(string: pic)
        if let realUrl = url {
            viPictureImageView.sd_setImage(with: realUrl)
        }
        
    }
    
}
