//
//  ForGetPassowViewController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 19/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD
import IQKeyboardManager

class ForGetPassowViewController: UIViewController {
    
    
    
    //手机号
    @IBOutlet weak var iphoneNumber: UITextField!
    
    //验证码
    @IBOutlet weak var code: UITextField!
    //获取验证码Label
    @IBOutlet weak var getCodeLab: UILabel!
    
    //新密码
    @IBOutlet weak var newPassword: UITextField!
    //确认新密码
    @IBOutlet weak var confirmNewPassword: UITextField!
    
    //获取验证码Label
    
    @IBOutlet weak var getCodeBtn: UIButton!
    @IBOutlet weak var navgaBackView: UIView!
    @IBAction func back() {
        
        iphoneNumber.resignFirstResponder()
        newPassword.resignFirstResponder()
        confirmNewPassword.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //倒计时剩余的时间
    var remainingSeconds = 0{
        
        willSet{
            
            getCodeBtn.setTitle("(\(newValue)s)", for: UIControlState())
            
            if newValue <= 0 {
                getCodeBtn.setTitle("重新获取", for: UIControlState())
                isCounting = false
            }
        }
    }
    
    //计时器
    var countDownTimer:Timer?
    
    //用于开启和关闭定时器
    var isCounting:Bool = false{
        
        willSet{
            if  newValue {
                countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats:true)
                
                getCodeBtn.backgroundColor = UIColor.gray
            }else
            {
                countDownTimer?.invalidate()
                countDownTimer = nil
                
                getCodeBtn.backgroundColor = UIColor.brown
            }
            
            getCodeBtn.isEnabled = !newValue
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        iphoneNumber.delegate = self
        code.delegate = self
        newPassword.delegate = self
        confirmNewPassword.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardReturnKeyHandler.init().lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //获取验证码
    @IBAction func getCode(_ sender:UIButton) {
        
        //       sender.enabled = false
        
        print("点击啦")
        let istrue = checkTel(iphoneNumber.text! as NSString)
        
        if istrue
        {
            yanzhengfunc()
        }
        else
        {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle:  "手机号码格式不正确")
            
        }
        
    }
    func yanzhengfunc(){
        
        
        User.SendPhoneCode(iphoneNumber.text!, order: "ResetPassword", success: { [weak self] in
            
            //启动计时器
            self!.remainingSeconds = 60
            self!.isCounting = true
            
        }) { (error) in
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle:  error.localizedDescription)
            
            
        }
    }
    
    
    //提交新密码
    @IBAction func submitBtn() {
        
        
        if checkFormat() {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            
            User.ResetPassword(iphoneNumber.text!, code: self.code.text!, password: self.newPassword.text!, success: {
                [weak self] in
                let strongSelf = self
                
                
                strongSelf!.dismiss(animated: true) {
                }
                })
            {[weak self] (error) in
                let strongSelf = self
                MBProgressHUD.hide(for: strongSelf!.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: error.localizedDescription)
                
            }
            
        }
        
    }
    
}

// MARK: - 点击按钮获取验证码

extension ForGetPassowViewController{
    
    //计时器事件
    func updateTime() -> Void {
        
        remainingSeconds -= 1
    }
    
    // 校验输入框格式
    
    func checkFormat() -> Bool{
        
        if iphoneNumber.text == nil || code.text == nil || newPassword.text == nil || confirmNewPassword.text == nil {
            return false
        }
        
        if (iphoneNumber.text! as NSString).length != 11 {
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: "手机号码格式错误")
            
            return false
        }else if code.text!.isEmpty{
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: "验证码不能为空")
            
            return false
        }else if newPassword.text!.isEmpty{
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: "密码不能为空")
            
            return false
            
        }else if confirmNewPassword.text!.isEmpty{
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: "请再次输入密码")
            
            return false
        }else if !(newPassword.text! as NSString).isEqual(to: confirmNewPassword.text!){
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: "两次输入密码不同")
            
            return false
        }
        
        return true
    }
}

// MARK: - UITextFieldDelegate

extension ForGetPassowViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField != confirmNewPassword {
            
            if textField == iphoneNumber {
                code.becomeFirstResponder()
            }
            
            if textField == code {
                newPassword.becomeFirstResponder()
            }
            
            if textField == newPassword {
                confirmNewPassword.becomeFirstResponder()
            }
        }else{
            confirmNewPassword.resignFirstResponder()
            
            submitBtn()
        }
        
        return true
    }
    
}


