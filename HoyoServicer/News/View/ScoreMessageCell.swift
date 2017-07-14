//
//  ScoreMessageCell.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/20.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class ScoreMessageCell: UITableViewCell {
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        creatUI()
        
    }
    
    func creatUI() {
        contentView.addSubview(orderLabel)
        contentView.addSubview(orderLb)
        contentView.addSubview(userLabel)
        contentView.addSubview(userLb)
        contentView.addSubview(gadeLabel)
        
        contentView.addSubview(gadeImage)
        contentView.addSubview(starImage)
        
        contentView.addSubview(contentLabel)
        contentView.addSubview(contentLb)
        contentView.addSubview(timeLabel)
        contentView.addSubview(timeLb)
        contentLb.numberOfLines = 0
        
        orderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        orderLb.adjustsFontSizeToFitWidth = true
        orderLb.snp.makeConstraints { (make) in
            make.left.equalTo(orderLabel.snp.right).offset(10)
            make.top.equalTo(orderLabel.snp.top)
            make.height.equalTo(orderLabel.snp.height)
            //  make.rightMargin.lessThanOrEqualTo(-10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
        }
        
        
        userLabel.snp.makeConstraints { (make) in
            make.top.equalTo(orderLabel.snp.bottom).offset(10)
            make.left.equalTo(self).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        userLb.snp.makeConstraints { (make) in
            make.left.equalTo(userLabel.snp.right).offset(10)
            make.top.equalTo(userLabel.snp.top)
            make.height.equalTo(userLabel.snp.height)
            make.rightMargin.lessThanOrEqualTo(-10)
            
        }
        
        gadeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userLabel.snp.bottom).offset(10)
            make.left.equalTo(self).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        
        starImage.snp.makeConstraints { (make) in
            make.top.equalTo(gadeLabel.snp.top).offset(9)
            make.left.equalTo(gadeLabel.snp.right).offset(10)
            make.width.equalTo(65)
            
        }
        
        gadeImage.snp.makeConstraints { (make) in
            make.top.equalTo(gadeLabel.snp.top).offset(9)
            make.left.equalTo(gadeLabel.snp.right).offset(10)
            make.width.equalTo(65)
            
        }
        
        
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(gadeLabel.snp.bottom).offset(10)
            make.left.equalTo(self).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        contentLb.preferredMaxLayoutWidth = MainScreenBounds.width - 80-15-10-10
        contentLb.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel.snp.right).offset(10)
            make.top.equalTo(contentLabel.snp.top).offset(6)
            make.right.equalTo(contentView.snp.right).offset(-10)
            //make.rightMargin.lessThanOrEqualTo(-10)
            //            make.height.greaterThanOrEqualTo(30)
            
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentLb.snp.bottom).offset(10)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
        
        timeLb.snp.makeConstraints { (make) in
            make.top.equalTo(contentLb.snp.bottom).offset(10)
            make.height.equalTo(30)
            make.left.equalTo(timeLabel.snp.right).offset(10)
            make.rightMargin.lessThanOrEqualTo(-10)
        }
        
    }
    
    func reloadUI(_ model: ScoreMessageModel) {
        
        let tmp =  model.messageCon
        if let data = tmp!.data(using: String.Encoding.utf8) {
            let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
            if dic != nil {
                orderLb.text = dic!!["Orderid"] as? String ?? ""
                userLb.text =  dic!!["Userid"] as? String ?? ""
                contentLb.text = dic!!["Remark"] as? String ?? ""
                let time:String = dic!!["CreateTime"] as? String ?? ""
                if time != "" {
                    let date = DateTool.dateFromServiceTimeStamp(time)
                    timeLb.text = DateTool.stringFromDate(date!, dateFormat: "YYYY-MM-dd HH:mm:ss")
                }
                
                let score: CGFloat  =   dic!!["Score"] as? CGFloat ?? 0
                starImage.snp.updateConstraints({ (make) in
                    let width = (score / 5.0) * 65
                    make.width.equalTo(width)
                })
            }
        }
        
    }
    
    
    
    
    //    private lazy var bootomView: ScoreBootomView = ScoreBootomView.init(frame: CGRectZero)
    
    //MARK: - 控件
    //订单
    fileprivate lazy var orderLabel: UILabel = RNBaseUI.createLabel("订       单:", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.center)
    fileprivate lazy var orderLb: UILabel = RNBaseUI.createLabel("12324121512712614T16416gtfrdr214172417", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.left)
    //用户ID
    fileprivate lazy var userLabel: UILabel = RNBaseUI.createLabel("用       户:", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.center)
    fileprivate lazy var userLb: UILabel = RNBaseUI.createLabel("", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.left)
    //评分 星级
    fileprivate lazy var gadeLabel: UILabel = RNBaseUI.createLabel("评       分:", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.center)
    fileprivate lazy var gadeImage: UIImageView = {
        let image = UIImageView(image: UIImage(named:"StarsBackground"))
        return image
    }()
    fileprivate lazy var starImage: UIImageView = {
        let image = UIImageView(image: UIImage(named:"StarsForeground"))
        image.clipsToBounds = true
        image.contentMode = UIViewContentMode.left
        return image
    }()
    //评论内容
    fileprivate lazy var contentLabel: UILabel = RNBaseUI.createLabel("评论内容:", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.center)
    fileprivate lazy var contentLb: UILabel = RNBaseUI.createLabel("的愿望电压为抵押给抵押给一点我gay的gay的尕娃有温度高亚安慰", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.left)
    //评论时间
    fileprivate lazy var timeLabel: UILabel = RNBaseUI.createLabel("评论时间:", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.center)
    fileprivate lazy var timeLb: UILabel = RNBaseUI.createLabel("", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.left)
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
}
