//
//  RNOtherFeeTypeTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/31.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNOtherFeeTypeTableViewCellDelegate {
    func updateData(_ index: IndexPath)
}

class RNOtherFeeTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moneyTextField: UITextField!
    
    var isCellSelected: Bool?
    
    var index: IndexPath?
    
    var feeTypeDic = [Int: String]()
    
    var myMoney = [Int: Double]()
    
    var delegate: RNOtherFeeTypeTableViewCellDelegate?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
         isCellSelected = false
        
        moneyTextField.isEnabled = false
        moneyTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        if isCellSelected! {
            
          //  self.textLabel?.textColor = UIColor.darkTextColor()
            self.accessoryType = UITableViewCellAccessoryType.checkmark
        }else{
           // self.textLabel?.textColor = UIColor.blackColor()
            self.accessoryType = UITableViewCellAccessoryType.none
        }
        
        UIView.commitAnimations()
    }

    
    func configCell(_ title: String, hasTitles:[String], hasFees:[Double], index: IndexPath){
        
        self.index = index
        titleLabel.text = "\(title)"
        
        for (i,value) in hasTitles.enumerated() {
            if value == title  {
                moneyTextField.text = "\(hasFees[i])"
                isCellSelected = true
                self.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
    }
    
    func changeSelectedState(_ ind: Int){
        isCellSelected = !isCellSelected!
        
        if isCellSelected! {
            
            moneyTextField.isEnabled = true
            moneyTextField.becomeFirstResponder()
           // feeTypeDic.updateValue((self.titleLabel?.text!)!, forKey: self.index!.row)
        }else{
           // feeTypeDic[self.index!.row] = nil
           // myMoney[self.index!.row] = nil
            
          //  self.delegate?.updateData(self.index!)
            
             moneyTextField.isEnabled = false
            
        }
        
        self.setNeedsLayout()
    }
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesMoved(touches, withEvent: event)
//        
//        
//        moneyTextField.resignFirstResponder()
//    }
//
    
}

extension RNOtherFeeTypeTableViewCell: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        // self.delegate?.inputSuccessToCaculateTotalMoney()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        isCellSelected = !isCellSelected!
//        
//        if isCellSelected! {
//            
//            moneyTextField.becomeFirstResponder()
//            feeTypeDic.updateValue((self.titleLabel?.text!)!, forKey: self.index!.row)
//        }else{
//            feeTypeDic[self.index!.row] = nil
//            myMoney[self.index!.row] = nil
//            
//            self.delegate?.updateData(self.index!)
//        }
//        
//        self.setNeedsLayout()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isCellSelected! {
           // let money = textField.text! == "" ? 0.0 : Double(textField.text!)!
           // myMoney.updateValue(money, forKey: index!.row)
        }else{
           // myMoney[index!.row] = nil
        }
        
       // self.delegate?.updateData(index!)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return textField.moneyFormatCheck(textField.text!, range: range, replacementString: string, remian: 2)
    }
    
}

