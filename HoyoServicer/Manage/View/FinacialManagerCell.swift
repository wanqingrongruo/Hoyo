//
//  FinacialManagerCell.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/6.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class FinacialManagerCell: UITableViewCell {
    
    var typeLable: UILabel = UILabel()
    var moneyLable: UILabel = UILabel()
    var timeLable: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func reloadUI(_ model:AccountDetailModel) {
        typeLable.text = model.payId
        moneyLable.text = model.money
        timeLable.text = model.createTime
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        typeLable.text = "安装收益"
        typeLable.font = UIFont.systemFont(ofSize: 15)
        typeLable.textAlignment = NSTextAlignment.center
        
        //        moneyLable.text = "123.8"
        moneyLable.font = UIFont.systemFont(ofSize: 15)
        moneyLable.textAlignment = NSTextAlignment.center
        
        //        timeLable.text = "星期五"
        timeLable.font = UIFont.systemFont(ofSize: 12)
        timeLable.textColor = UIColor.lightGray
        timeLable.textAlignment = NSTextAlignment.center
        addSubview(typeLable)
        addSubview(moneyLable)
        addSubview(timeLable)
        typeLable.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(10)
            make.height.equalTo(30)
           // make.width.equalTo(WIDTH_SCREEN/2)
            //            make.right.lessThanOrEqualTo(-200)
        }
        moneyLable.snp.makeConstraints { (make) in
            make.top.equalTo(typeLable.snp.top).offset(0)
            make.height.equalTo(30)
            make.leading.equalTo(typeLable.snp.right).offset(10)
            make.trailing.greaterThanOrEqualTo(10)
            make.width.equalTo(50)
        }
        timeLable.snp.makeConstraints { (make) in
            make.top.equalTo(typeLable.snp.bottom).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(10)
            make.trailing.lessThanOrEqualTo(contentView.snp.trailing).offset(-10)
            make.bottom.equalTo(-10)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
