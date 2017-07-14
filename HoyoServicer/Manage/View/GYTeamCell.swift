//
//  GYTeamCell.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class GYTeamCell: UITableViewCell {
    
    /// 本地数据
    var  fixedName: UILabel?
    /// 网络数据
    var  netWorkLb: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        fixedName = RNBaseUI.createLabel("", titleColor: UIColor.black, font: 17, alignment: NSTextAlignment.left)
        
        netWorkLb = RNBaseUI.createLabel("", titleColor: UIColor.black, font: 17, alignment: NSTextAlignment.left)
        netWorkLb?.numberOfLines = 0
        addSubview(fixedName!)
        addSubview(netWorkLb!)
        
        fixedName?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView).offset(15)
            make.left.equalTo(self.contentView).offset(10)
            make.width.equalTo(102)
            //            make.bottom.equalTo(contentView).offset(-7.5)
        })
        
        netWorkLb?.snp.makeConstraints({ (make) in
            make.top.equalTo(contentView).offset(15)
            make.left.equalTo(fixedName!.snp.right).offset(15)
            make.width.equalTo(WIDTH_SCREEN - 137)
            
            make.bottom.equalTo(contentView).offset(-7.5)
            //            make.height.greaterThanOrEqualTo(100)
        })
        
    }
    
    
    func reloadUI(_ str:String,str2: String) {
        fixedName?.text = str
        if str2 == "" {
            netWorkLb?.text = "暂无"
        } else {
            netWorkLb?.text = str2
        }
    }
    
    func heightForText(_ text: NSString) -> CGFloat {
        
        let attrbute = [NSFontAttributeName:UIFont.systemFont(ofSize: 17)];
        
        return text.boundingRect(with: CGSize(width:WIDTH_SCREEN - 137, height: 1000) , options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attrbute, context: nil).size.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
