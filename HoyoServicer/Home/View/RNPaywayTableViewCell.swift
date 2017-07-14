//
//  RNPaywayTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/31.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNPaywayTableViewCellDelegate {
    
    func updateUI()
}

class RNPaywayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var totalFeeLabel: UILabel! // 合计
    @IBOutlet weak var payDecLabel: UILabel! // 选择支付方式的描述
    

    var delegate: RNPaywayTableViewCellDelegate? // 代理
    var selectedIndex = 0 //  现金已支付5-微信支付6-无需支付按钮7 索引,默认都不选中
    var payWay: String = "Money" //支付方式

    
    // 支付方式选择
    @IBAction func payTypeAction(_ sender: UIButton) {
        // tag=5 现金已支付 -- 默认选择
        // tag=6 微信支付 -- 上方服务费用输入框显示,否则隐藏
        // tag=7 无需支付
        // tag=8 pos机支付
        
        guard !sender.isSelected else{ // 已是选中状态则不作任何操作
            return
        }
        
        if selectedIndex != 0 {
            // 取消选择
            let lastButton = self.viewWithTag(selectedIndex) as! UIButton
            lastButton.isSelected = false
            lastButton.backgroundColor = UIColor.white
            
        }
        
        
        sender.isSelected = true
        sender.backgroundColor = COLORRGBA(246, g: 116, b: 10, a: 1)
        selectedIndex = sender.tag
        
        
        //let serviceFee = totalFeeLabel.text!
        
        if sender.tag == 6 { // 选择微信支付时, 服务费用 View显示 ,否则不显示
            
            payWay = "124010020"
            
           // payDecLabel.text = "稍后客户要在微信端,支付\(serviceFee)"
        }else{
            
            if sender.tag == 5 {
                payWay = "124020040"
                
               // payDecLabel.text = "确认已收到客户现金支付\(serviceFee),需要提交给公司\(serviceFee)"
            }else if sender.tag == 7 {
                payWay = "124010040"
              //  payDecLabel.text = ""
            }else{
                payWay = "124010001"
              //  payDecLabel.text = "已在Pos机上刷卡进行支付"
            }
        }
        
        
        self.delegate?.updateUI()
        
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


