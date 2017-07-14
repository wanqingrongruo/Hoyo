//
//  RNInstallInfoTableViewCell.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/3/15.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNInstallInfoCellDelegate: class{
    // 选择区域
    func selectAreaInfo()
    // 扫描二维码
    func scanQRInfo(tag: Int)
    // 确定
    func confirmInfo()
    
    func reloadUI()
}

class RNInstallInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView! // 父视图
    @IBOutlet weak var nameTextField: UITextField! // 客户姓名
    @IBOutlet weak var phoneNumLabel: UILabel! // 手机号 -- 上个界面带来
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var optionalPhoneView: UIView! // 备选号码 view,初始状态隐藏
    @IBOutlet weak var optionalTextField: UITextField! // 备选号码输入框
    @IBOutlet weak var areaLabel: UILabel! // 所在地区
    @IBOutlet weak var areaView: UIView!
    @IBOutlet weak var adreessTextField: UITextField! // 详细地址
    @IBOutlet weak var machineIDLabel: UILabel! // 机器型号 -- 二维码
    @IBOutlet weak var productIDTextField: UITextField! // 机器 ID
    @IBOutlet weak var IMEIIDLabel: UILabel! // IMEI -- 二维码
    @IBOutlet weak var installerTextField: UITextField! // 安装人
    @IBOutlet weak var tvSuperView: UIView! // tvPlaceHolderLabel and remarkTextView 的父视图
    @IBOutlet weak var tvPlaceHolderLabel: UILabel! // textView 的 占位符
    @IBOutlet weak var remarkTextView: UITextView! // 备注 -- 200字以内
    @IBOutlet weak var confirmButton: UIButton! // 确认按钮
    
    @IBOutlet weak var areaViewTop: NSLayoutConstraint!
    @IBOutlet weak var optionalPhotoViewHeight: NSLayoutConstraint!
 
    
    weak var delegate: RNInstallInfoCellDelegate?
    
    var hasPlaceHolder = true // tvPlaceHolderLabel 是否存在
    
    var myOptionalView = UIView()
    
    // 添加备选号码
    @IBAction func addOptionalPhone(_ sender: UIButton) {
        
        optionalPhoneView.isHidden = false
        areaViewTop.constant = 2 + optionalPhotoViewHeight.constant

        optionalTextField.delegate = self
        
      
        
        self.delegate?.reloadUI()
    }
    // 选择区域
    @IBAction func slectArea(_ sender: UIButton) {
        self.delegate?.selectAreaInfo()
    }
    
    // 扫描二维码
    @IBAction func scanQR(_ sender: UIButton) {
         self.delegate?.scanQRInfo(tag: sender.tag)
    }
    
    // 确定
    @IBAction func confirmAction(_ sender: UIButton) {
         self.delegate?.confirmInfo()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       // myOptionalView = optionalPhoneView
       // optionalPhoneView.removeFromSuperview()
        optionalPhoneView.isHidden = true
        
        remarkTextView.delegate = self
        
        productIDTextField.delegate = self

        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 23
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
}

extension RNInstallInfoTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.optionalTextField {
            
            if (textField.text!.characters.count == 11) && textField.text!.phoneFormatCheck() {
                
            }else{
                
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "手机号码格式错误")
            }
        }
        

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === self.productIDTextField {
            
            if textField.digitFormatCheck(textField.text!, range: range, replacementString: string) {
                return true
            }else{
                
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "只能输入数字")
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        optionalTextField.resignFirstResponder()
        return true
    }

}

extension RNInstallInfoTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if hasPlaceHolder {
            tvPlaceHolderLabel.isHidden = true
            hasPlaceHolder = false
        }
       
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            tvPlaceHolderLabel.isHidden = false
            hasPlaceHolder = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (textView.text as NSString).length > 100 {
            textView.text = (textView.text as NSString).substring(to: 100)
            textView.resignFirstResponder()
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showWarning("提示", subTitle: "输入不能超过100个字")
        }
    }

}
