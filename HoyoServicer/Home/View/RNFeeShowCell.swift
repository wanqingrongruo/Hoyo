//
//  RNFeeShowCell.swift
//  airfightSex
//
//  Created by zhuguangyang on 16/9/23.
//  Copyright © 2016年 giant. All rights reserved.
//

import UIKit

//protocol RNFeeShowCellDelegate {
//    
//    // 输入完成计算总金额
//    func inputSuccessToCaculateTotalMoney()
//    
//    func updateUI()
//    
//}


class RNFeeShowCell: UITableViewCell {
    
//    var delegate: RNFeeShowCellDelegate? // 代理
//    var selectedIndex = 0 //  现金已支付5-微信支付6-无需支付按钮7 索引,默认都不选中
//    var payWay: String = "Money" //支付方式
    // 自定义属性
    var orderDetails: OrderDetail? // 订单详情
    var payInfos = [RNPAYDetailModel]() // 支付信息
    var payMoney: Double = 0.00 // 支付金额

    @IBOutlet weak var productsFeeLabel: UILabel! // 配件费用
    
    
    @IBOutlet weak var payDetailView: UIView! // 支付信息展示
    
//    // 支付方式选择
//    @IBAction func payTypeAction(sender: UIButton) {
//        // tag=5 现金已支付 -- 默认选择
//        // tag=6 微信支付 -- 上方服务费用输入框显示,否则隐藏
//        // tag=7 无需支付
//        
//        guard !sender.selected else{ // 已是选中状态则不作任何操作
//            return
//        }
//        
//        if selectedIndex != 0 {
//            // 取消选择
//            let lastButton = self.viewWithTag(selectedIndex) as! UIButton
//            lastButton.selected = false
//            lastButton.backgroundColor = UIColor.whiteColor()
//
//        }
//        
//        
//        sender.selected = true
//        sender.backgroundColor = COLORRGBA(246, g: 116, b: 10, a: 1)
//        selectedIndex = sender.tag
//        
//        
//        let serviceFee = totalFeeLabel.text!
//        
//        if sender.tag == 6 { // 选择微信支付时, 服务费用 View显示 ,否则不显示
//            
//            payWay = "124010020"
//            
//            payDecLabel.text = "稍后客户要在微信端,支付\(serviceFee)"
//        }else{
//            
//            if sender.tag == 5 {
//                payWay = "124020040"
//               
//                payDecLabel.text = "确认已收到客户现金支付\(serviceFee),需要提交给公司\(serviceFee)"
//            }else if sender.tag == 7 {
//                payWay = "124010040"
//                payDecLabel.text = ""
//            }else{
//                payWay = "124010001"
//                payDecLabel.text = "已在Pos机上刷卡进行支付"
//            }
//        }
//        
//        
//        self.delegate?.updateUI()
//        
//    }
//    
    
    


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       // otherFeeTextField.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        
        //self.delegate?.inputSuccessToCaculateTotalMoney()
    }
    
    // 显示数据
    func configCell(_ orderDetail: OrderDetail, payInfos: [RNPAYDetailModel]){
        
        var lastView: RNFeeTypeView02?
        for (index,value) in payInfos.enumerated() {
            
            let newView = Bundle.main.loadNibNamed("RNFeeTypeView02", owner: self, options: nil)?.last as! RNFeeTypeView02
            newView.typeLabel.text = value.PayTitle
            
            guard value.Money != nil else{
                return
            }
            
            let price = String(format: "%.2f", value.Money!/100.0)
            newView.priceLabel.text = price
            if value.PayState == "128000010" {
                
                newView.payStatusLabel.text = "未支付"
            }else if value.PayState == "128010020"{
                newView.payStatusLabel.text = "已支付"
            }

            payDetailView.addSubview(newView)
            
            if lastView == nil {
                newView.snp.makeConstraints({ (make) in
                    make.top.equalTo(5)
                    make.leading.equalTo(0)
                    make.trailing.equalTo(0)
                })
                
                if index == payInfos.count - 1 {
                    newView.snp.makeConstraints({ (make) in
                        make.bottom.equalTo(payDetailView.snp.bottom).offset(-10)
                    })
                }
            }else{
                
                newView.snp.makeConstraints({ (make) in
                    make.top.equalTo(lastView!.snp.bottom).offset(5)
                    make.leading.equalTo(0)
                    make.trailing.equalTo(0)
                })
                
                if index == payInfos.count - 1 {
                    newView.snp.makeConstraints({ (make) in
                        make.bottom.equalTo(payDetailView.snp.bottom).offset(-10)
                    })
                }
            }
            
            lastView = newView
            
        }

    }
    
}

//extension RNFeeShowCell: UITextFieldDelegate{
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//    
//        textField.resignFirstResponder()
//        
//       // self.delegate?.inputSuccessToCaculateTotalMoney()
//        
//        return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//        
//         self.delegate?.inputSuccessToCaculateTotalMoney()
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        
//        return textField.moneyFormatCheck(textField.text!, range: range, replacementString: string, remian: 2)
//    }
//    
//}
