//
//  SubmitListsCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 21/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
protocol SubmitListsCellDelegate {
    func  pushNumbersToCon(_ numbers:Int,row:Int)
}
class SubmitListsCell: UITableViewCell {
      var delegate:SubmitListsCellDelegate?
//产品名字
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    //购买数量
    @IBOutlet weak var shopNumber: UILabel!
    
    //操作购买数额
    @IBOutlet weak var reduceOrAdd: UIStepper!
        var row :Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      //  reduceOrAdd.value=Double(1)
     self.shopNumber.text="1"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func  showText(_ productInfo:ProductInfo,row:Int,number:NSNumber)
    {
        self.productName.text = productInfo.name
        self.priceLabel.text = productInfo.price
        //  self.shopNumber.text = productInfo.last
        self.row=row
        if number != 0{
        self.shopNumber.text="\(number)"
        self.reduceOrAdd.value=Double(number)
        }
     //   reduceOrAdd.value = Double(self.shopNumber.text!)!
        
    }
    

    
    @IBAction func reduceOrAdd(_ sender: AnyObject) {
   
        print(sender.stepValue)
      
      
//   self.shopNumber.text = "\( Double(self.shopNumber.text!)!  + (sender as! UIStepper).stepValue)"
        
        self.shopNumber.text = "\(Int((sender as! UIStepper).value))"
        delegate?.pushNumbersToCon((self.shopNumber.text! as NSString).integerValue, row: row!)
        
    }
}
