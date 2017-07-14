//
//  GetMoneyCell.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 12/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

typealias myClosure = (UIButton) -> Void

@objc
public protocol GetMoneyCellDelegate {
    
    //添加银行卡界面(根据数据源是否有数据判定动作)
    @objc optional func selecetBankCard(_ button:UIButton)
    
    //提现成功跳转进去提现详情界面

    func pushToDetailView()
}

class GetMoneyCell: UITableViewCell,UITextFieldDelegate {
    
    
    @IBOutlet weak var bankCardButton: UIButton!
    
    //选择银行卡/如果没有绑定银行卡,跳入绑定界面
    @IBAction func selectBankCard(_ sender: UIButton) {
        
        //delegate?.selecetBankCard!(sender)
        
        if (selectBankClosure != nil) {
            selectBankClosure!(sender)
        }
    }
    
    @IBOutlet weak var getMoneyTextField: UITextField!
    

   
    //全部提现
    @IBAction func getAllMoney() {
        
        
    }
    
    //提现
    @IBAction func getMoney() {
        delegate?.pushToDetailView()
    }
    
    //代理
     var delegate :GetMoneyCellDelegate?
    //选择银行卡回调
    var selectBankClosure:myClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bankCardButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        getMoneyTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

// MARK: - UITextFieldDelegate

extension getMoneyDetailCell{
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
        return moneyInput(textField.text!, range: range, replaceString: string, remain: 2)
    }

    
}


// MARK: - 限制输入框只能输入两位有效数字

extension getMoneyDetailCell{
    
    /**
     输入框输入限制
     此方法作为返回值放入UITextFieldDelegate的 func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool 中
     1.只能输入数字和小数点
     2.保留几位
     3.一般用于钱的输入
     
     - parameter text:     输入框中的已输入字符串
     - parameter range:         范围
     - parameter replaceString: 即将输入的字符
     - parameter remain:        保留小数位数
     
     - returns: 是否可输入
     */
    func moneyInput(_ text: String, range: NSRange, replaceString: String, remain: Int) -> Bool {
        
        var inputText = text
        
        let scanner = Scanner(string: inputText)
        var numbers:CharacterSet
        
        //字符串限制的可输入字符
        let pointRange:NSRange = (inputText as NSString).range(of: ".")
        if (pointRange.length > 0) && (pointRange.location < range.location || pointRange.location > range.location + range.length) {
            numbers = CharacterSet.init(charactersIn: "0123456789")
        }else{
            numbers = CharacterSet.init(charactersIn: "0123456789.")
        }
        
        //拒绝输入空和小说点
        if (inputText as NSString).isEqual(to: "") && (inputText as NSString).isEqual(to: ".") {
            return false
        }
        
        let tempStr = inputText + replaceString
        let strlen = (tempStr as NSString).length
        
        if pointRange.length > 0 && pointRange.location > 0 { //判断输入框是否含有"."
            if (replaceString as NSString).isEqual(to: ".") {  //当输入框已含有"."时,如果再输入".",则视为无效
                return false
            }
            
            if strlen > 0 && (strlen - pointRange.location) > (remain + 1) { //当输入框内已经含有“.”，当字符串长度减去小数点前面的字符串长度大于需要要保留的小数点位数，则视当次输入无效。
                return false
            }
        }
        
        let zeroRange:NSRange = (inputText as NSString).range(of: "0")
        if zeroRange.length == 1 && zeroRange.location == 0 { //判断输入框第一个字符是否为"0"
            if !(replaceString as NSString).isEqual(to: "0") && !(replaceString as NSString).isEqual(to: ".") { //当输入框只有一个字符并且字符为“0”时，再输入不为“0”或者“.”的字符时，则将此输入替换输入框的这唯一字符。
                inputText = replaceString
                return false
            }else{
                
                if pointRange.length == 0 && pointRange.location > 0 { ////当输入框第一个字符为“0”时，并且没有“.”字符时，如果当此输入的字符为“0”，则视当此输入无效。

                    if (replaceString as NSString).isEqual(to: "0") {
                        return false
                    }
                }
            }
        }
        
        var  buffer:NSString?
        if !scanner.scanCharacters(from: numbers, into: &buffer) && (replaceString as NSString).length != 0 {
            return false
        }
        
        return true
    }
}

