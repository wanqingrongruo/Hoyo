//
//  DetailTableViewCell3.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 11/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class DetailTableViewCell3: UITableViewCell {

    //提成金额
    @IBOutlet weak var money: UILabel!
    
    //扣款金额
    @IBOutlet weak var debitMoney: UILabel!
    
    //上级金额
    @IBOutlet weak var higherMoney: UILabel!
    
    //结算时间
    @IBOutlet weak var settleTime: UILabel!
    
    //扣款备注
    @IBOutlet weak var remark: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showDetail3Text(_ settlementinfoDetail :Settlementinfo)  {
     self.debitMoney.text = "\((settlementinfoDetail.debitMoney! as NSString).doubleValue)"
        self.higherMoney.text = "\((settlementinfoDetail.higherMoney! as NSString).doubleValue)"
        self.money.text = "\((settlementinfoDetail.money! as NSString).doubleValue)"
        self.remark.text = settlementinfoDetail.remark
        let  timeStamp  =  DateTool.dateFromServiceTimeStamp(settlementinfoDetail.settleTime! )!
        self.settleTime.text =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy年MM月dd日")
    }
    
}
