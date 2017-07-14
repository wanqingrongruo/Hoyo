//
//  HistoryTableViewCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 8/6/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var orderID: UILabel!
    
    @IBOutlet weak var arriveTime: UILabel!
    
    @IBOutlet weak var remark: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func showHistoryText(_ history:HistoryList){
        self.orderID.text=history.id
        if history.arriveTime == "" {
            self.arriveTime.text = "无"
        }else{
            let  timeStamp  =  DateTool.dateFromServiceTimeStamp(history.arriveTime! )!
            //cell.remark.text   =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy-MM-dd")+" "+self.scorelists[indexPath.row-1].remark!
            self.arriveTime.text =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy年MM月dd日 HH:MM")
        }
        
        self.remark.text=history.remark
    
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
