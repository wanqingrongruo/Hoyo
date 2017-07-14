//
//  NewsTableViewCell.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/29.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SDWebImage

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var nickName: UILabel!
    @IBOutlet var iconImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func reloadUI(_ model:MessageModel) {
        timeLabel.text = model.createTime
        if model.messageCon == "有新的订单可以抢~" {
            //            nickName.text = "系统通知"
            nickName.text = model.sendNickName
            iconImage.image = UIImage(named: "sys_msg")
            stateLabel.text = model.messageCon
            return
        }
        
        nickName.text = model.sendNickName
        if model.sendImageUrl != "" {
            
            if model.sendImageUrl!.contains("http://") {
                iconImage.sd_setImage(with: URL(string: model.sendImageUrl!), placeholderImage: UIImage(named: "DefaultHeadImg"))
            } else {
                iconImage.sd_setImage(with: URL(string: SERVICEADDRESS + model.sendImageUrl!), placeholderImage: UIImage(named: "DefaultHeadImg"))
            }
            
        } else {
            iconImage.image = UIImage(named: "DefaultHeadImg")
        }
        
        if model.messageType == "score" {
            let tmp =  model.messageCon
            if let data = tmp!.data(using: String.Encoding.utf8) {
                let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
                if dic != nil {
                    stateLabel.text = dic!!["Remark"] as? String
                }
            }
        } else {
            stateLabel.text = model.messageCon
        }
        //        let numStr:String = (NSUserDefaults.standardUserDefaults().valueForKey("messageNum") ?? "0") as! String
        
        //        if numStr == "0" {
        //            stateLabel.text = "暂无未读消息"
        //            stateLabel.textColor = UIColor.lightGrayColor()
        //        } else {
        //            stateLabel.text = "您有\(numStr)条消息未读，请及时打开。"
        //            stateLabel.textColor = UIColor.redColor()
        //        }
    }
    func reloadScoreUI(_ model:ScoreMessageModel) {
        timeLabel.text = model.createTime
        nickName.text = model.sendNickName
        if model.sendImageUrl != "" {
            
            if model.sendImageUrl!.contains("http://") {
                iconImage.sd_setImage(with: URL(string: model.sendImageUrl!), placeholderImage: UIImage(named: "DefaultHeadImg"))
            } else {
                iconImage.sd_setImage(with: URL(string: SERVICEADDRESS + model.sendImageUrl!), placeholderImage: UIImage(named: "DefaultHeadImg"))
            }

        }
        
        let numStr:String = (UserDefaults.standard.value(forKey: "scoreNum") ?? "0") as! String
        
        if numStr == "0" {
            stateLabel.text = "暂无未读消息"
            stateLabel.textColor = UIColor.lightGray
        } else {
            stateLabel.text = "您有\(numStr)条消息未读，请及时打开。"
            stateLabel.textColor = UIColor.red
        }
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
