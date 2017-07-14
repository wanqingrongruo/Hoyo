//
//  ScoreBootomView.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/20.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SnapKit

class ScoreBootomView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    /// 保存配图的宽度约束
    var picturWidthCons: NSLayoutConstraint?
    
    fileprivate func setupUI() {
        backgroundColor = UIColor.white
        addSubview(orderLabel)
        addSubview(orderLb)
        addSubview(userLabel)
        addSubview(userLb)
        addSubview(gadeLabel)
        addSubview(gadeImage)
        addSubview(starImage)
        starImage.clipsToBounds = true
        starImage.contentMode = UIViewContentMode.left
        addSubview(contentLabel)
        addSubview(contentLb)
        addSubview(timeLabel)
        addSubview(timeLb)
        contentLb.numberOfLines = 0

        orderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        orderLb.adjustsFontSizeToFitWidth = true
        orderLb.snp.makeConstraints { (make) in
            make.left.equalTo(orderLabel.snp.right).offset(10)
            make.top.equalTo(orderLabel.snp.top)
            make.height.equalTo(orderLabel.snp.height)
          //  make.rightMargin.lessThanOrEqualTo(-10)
            make.trailing.equalTo(self.snp.trailing).offset(-10)
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
        
        gadeImage.snp.makeConstraints { (make) in
            make.top.equalTo(gadeLabel.snp.top).offset(9)
            make.left.equalTo(gadeLabel.snp.right).offset(-10)
            make.width.equalTo(65)
            
        }
        
        starImage.snp.makeConstraints { (make) in
            make.top.equalTo(gadeLabel.snp.top).offset(9)
            make.left.equalTo(gadeLabel.snp.right).offset(10)
            make.width.equalTo(65)
            //            picturWidthCons?.constant = 10
        }
        
        //        starImage.addConstraint(picturWidthCons!)
        // 星
        //        CGFloat starCount = [model.starCurrent floatValue];
        //        _starConstraint_w.constant = 65 * starCount / 5;
        //@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starConstraint_w;
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(gadeLabel.snp.bottom).offset(10)
            make.left.equalTo(self).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        contentLb.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel.snp.right).offset(10)
            make.top.equalTo(contentLabel.snp.top)
            make.rightMargin.lessThanOrEqualTo(-10)
            make.height.greaterThanOrEqualTo(30)
            
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentLb.snp.bottom).offset(10)
            make.left.equalTo(self).offset(15)
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.bottom.equalTo(self).offset(-10)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        return image
    }()
    //评论内容
    fileprivate lazy var contentLabel: UILabel = RNBaseUI.createLabel("评论内容:", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.center)
    fileprivate lazy var contentLb: UILabel = RNBaseUI.createLabel("的愿望电压为抵押给抵押给一点我gay的gay的尕娃有温度高亚安慰", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.left)
    //评论时间
    fileprivate lazy var timeLabel: UILabel = RNBaseUI.createLabel("评论时间:", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.center)
    fileprivate lazy var timeLb: UILabel = RNBaseUI.createLabel("", titleColor: UIColor.black, font: 15, alignment: NSTextAlignment.left)
    
}
