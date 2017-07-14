//
//  RNProductCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/2/23.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNProductCell: UITableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(product: ProductInfo){
        
//        productNameLabel.text = product.name
//        priceLabel.text = product.price
//        amountLabel.text = String(describing: product.numbers)
    }
    
}
