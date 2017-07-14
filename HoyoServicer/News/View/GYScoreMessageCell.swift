//
//  GYScoreMessageCell.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/20.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class GYScoreMessageCell: UITableViewCell {
    
    
    
    @IBOutlet weak var starImage_width: NSLayoutConstraint!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var orderNum: UILabel!
    @IBOutlet weak var payWay: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        starImage.clipsToBounds = true
        starImage.contentMode = UIViewContentMode.left
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func reloadUI(_ model: ScoreMessageModel) {
        
        let tmp =  model.messageCon
        if let data = tmp!.data(using: String.Encoding.utf8) {
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
                if dic != nil {
                    orderNum.text = dic!["Orderid"] as? String ?? ""
                    contentLabel.text = dic!["Remark"] as? String ?? ""
                    payWay.text = dic!["Way"] as? String ?? ""
                    ipLabel.text = dic!["Ip"] as? String ?? ""
                    let time:String = dic!["CreateTime"] as? String ?? ""
                    if time != "" {
                        //                        let date = DateTool.dateFromServiceTimeStamp(time)
                        //DateTool.stringFromDate(date!, dateFormat: "YYYY-MM-dd HH:mm:ss")
                        timeLabel.text = time
                    } else {
                        timeLabel.text = "时间都去哪儿了"
                    }
                    
                    let score: CGFloat  =   dic!["Score"] as? CGFloat ?? 0
                    starImage_width.constant =  (score/5.0) * 65
                }
            } catch {
                print(error)
            }
        }
    }
}
