//
//  RNNewAddBankViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/26.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD

//class IsEditTextField: UITextField {
//    override var isEditing: Bool {
//        return false
//    }
//}

class RNNewAddBankViewController: UIViewController {
    
    @IBOutlet weak var bankNameTextField: UITextField!
    
    @IBOutlet weak var branchNameTextField: UITextField!
    
    @IBOutlet weak var bankCodeTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBAction func selectBank(_ sender: UIButton) {
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        bingdingBankCard()
    }
    
    var params = [String: Any]() //参数列表
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "添加银行卡"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        saveButton.layer.cornerRadius = 20
        bankCodeTextField.delegate = self
        phoneTextField.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = false
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // navigationController?.setNavigationBarHidden(true, animated: animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - UITextFieldDelegate

extension RNNewAddBankViewController: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //        if textField === self.phoneTextField {
        //
        //            if (textField.text!.characters.count == 11) && textField.text!.phoneFormatCheck() {
        //
        //            }else{
        //
        //                let alertView = SCLAlertView()
        //                alertView.addButton("确定", action: {})
        //                alertView.showError("提示", subTitle: "手机号码格式错误")
        //            }
        //        }
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === self.phoneTextField || textField == self.bankCodeTextField {
            
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
    
}


//MARK: - private methods

extension RNNewAddBankViewController {
    
    func setUI(){
        
    }
    
    func mergeparams() -> Bool {
        
        guard let bankName = bankNameTextField.text, bankName != "" else {
            showErrorTips("请填写银行名称", "确定", "提示")
            return false
        }
        
        guard let branchName = branchNameTextField.text, branchName != "" else {
            showErrorTips("请填写支行名称", "确定", "提示")
            return false
        }
        
        guard let bankCode = bankCodeTextField.text, bankCode != "" else {
            showErrorTips("请填写银行卡号", "确定", "提示")
            return false
        }
        
        guard let name = nameTextField.text, name != "" else {
            showErrorTips("请填写姓名", "确定", "提示")
            return false
        }
        
        // 手机号码校验
        //  (phoneTextField!.characters.count == 11) && phoneTextField!.phoneFormatCheck()
        
        guard let phone = phoneTextField.text, phone.characters.count == 11, phone.phoneFormatCheck() else {
            showErrorTips("手机号码格式错误或未填", "确定", "提示")
            return false
        }
        
        
        params["openingbank"] = bankName
        params["branchbank"] = branchName
        params["cardid"] = bankCode
        params["realname"] = name
        params["cardphone"] = phone
        
        self.view.endEditing(true)
        
        return true
        
    }
    
    // 错误提示
    func showErrorTips(_ errorInfo: String, _ title: String, _ tip: String){
        let alertView = SCLAlertView()
        alertView.addButton(title, action: {})
        alertView.showError("提示", subTitle: errorInfo)
    }
    
    func bingdingBankCard() -> Void {
        //绑定验证
        
        if mergeparams() {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            User.BindNewBlankCard2(params, success: { [weak self] in
                //验证成功跳转回navigation第二层(所有绑定的银行卡界面/提现界面)
                
                MBProgressHUD.hide(for: self!.view, animated: true)
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {
                    guard let vcs = self?.navigationController?.viewControllers, vcs.count >= 2 else {
                        return
                    }
                    
                    let viewController = vcs[1]
                    
                    //这里强制解包可能存在问题
                    if viewController.isMember(of: BoundBankCardViewController.self){
                        
                        let vc = viewController as! BoundBankCardViewController
                        vc.downloadDataFromServer()
                        _ = self!.navigationController?.popToViewController(vc, animated: true)
                    }else if viewController.isMember(of: GetMoneyViewController.self){
                        let vc = viewController as! GetMoneyViewController
                        vc.downloadBankListFromServer()
                        _ = self!.navigationController?.popToViewController(vc, animated: true)
                    }
                    
                })
                alertView.showSuccess("提示", subTitle: "绑定成功")
                
                
                }, failure: { [weak self](error) in
                    
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let alertView=SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("错误提示", subTitle: error.localizedDescription)
                    
            })
            
        }
        
    }
    
}

//MARK: - event response

extension RNNewAddBankViewController {
    
    func disMissBtn(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
