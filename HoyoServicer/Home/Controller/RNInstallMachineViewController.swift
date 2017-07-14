//
//  RNInstallMachineViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/3/15.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD

class RNInstallMachineViewController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var verifyCodeTextField: UITextField!
    
    @IBOutlet weak var verifyCodeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func cilckAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            // 获取验证码
            // 1. 号码校验
            guard  getVerifyCodeCheck(phoneTextField.text) else {
                return
            }
            // 2. 请求验证码
            getCode(phoneTextField.text!)
            break
        case 200:
            // 检验验证码是否正确
            submitAction()
            break
        default:
            break
        }
        
    }
    
    //倒计时剩余的时间
    var remainingSeconds = 0{
        
        willSet{
            
            verifyCodeButton.setTitle("(\(newValue)s)", for: UIControlState())
            
            if newValue <= 0 {
                verifyCodeButton.setTitle("重新获取", for: UIControlState())
                isCounting = false
            }
        }
    }
    
    //计时器
    var countDownTimer:Timer?
    
    //用于开启和关闭定时器
    var isCounting:Bool = false{
        
        willSet{
            if  newValue
            {
                countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats:true)
                
                verifyCodeButton.backgroundColor = UIColor.gray
            }
            else
            {
                countDownTimer?.invalidate()
                countDownTimer = nil
                
                verifyCodeButton.backgroundColor = UIColor.brown
            }
            
            verifyCodeButton.isEnabled = !newValue
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "验证手机号码"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        setupUI()
        
    }
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
//        
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
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
    
}

// MARK: - custom methods

extension RNInstallMachineViewController {
    
    final func setupUI(){
        
        verifyCodeButton.layer.masksToBounds = true
        verifyCodeButton.layer.cornerRadius = 18
        
        nextButton.layer.masksToBounds = true
        nextButton.layer.cornerRadius = 23
        
        let left01 = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 40))
        phoneTextField.leftViewMode = .always
        phoneTextField.leftView = left01
        
        let left02 = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 40))
        verifyCodeTextField.leftViewMode = .always
        verifyCodeTextField.leftView = left02
        
        phoneTextField.delegate = self
        verifyCodeTextField.delegate = self

    }
    
     // 获取验证码
    func getCode(_ phoneNum: String) {
        
        verifyCodeButton.isEnabled = false
        //调用发送验证码接口
        User.GetCodeForInstallingMachine(mobile: phoneTextField.text!, order: "QianYeUserInstall", scope: nil, success: { [weak self] in
            //启动计时器
            self!.remainingSeconds = 60
            self!.isCounting = true

        }) { (error) in
            self.verifyCodeButton.isEnabled = true
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle: error.localizedDescription)
        }
      
    }
    
    // 获取验证码前校验
    
    func getVerifyCodeCheck(_ phoneNum: String? ) -> Bool {
        
        guard let phone = checkPhoneEmpty(phoneNum) else {
            
            // 提示
            showErrorTips("手机号码不能为空", "确定", "提示")
            return false
        }
        
        // 手机号码格式
        guard phoneFormat(phone) else {
            showErrorTips("手机号码格式不正确", "确定", "提示")
            return false
        }
        
        return true

    }
    
    // 按钮校验事件
    func checkIsEmpty() -> Bool {
        
        guard let phone = checkPhoneEmpty(phoneTextField.text) else {
            
            // 提示
            showErrorTips("手机号码不能为空", "确定", "提示")
            return false
        }
        
        // 手机号码格式
        guard phoneFormat(phone) else {
            showErrorTips("手机号码格式不正确", "确定", "提示")
            return false
        }
        
        guard let _ = verifyCodeTextField.text else {
            showErrorTips("验证码不能为空", "确定", "提示")
            return false
        }
        
        return true
    }
    
   
    
    // 验证码非空校验
    func checkVerifyCode(_ verifyCode: String) -> Bool {
        
        guard verifyCode.characters.count == 0 else {
            return false
        }
        
        return true
    }
    
    // 手机号非空校验
    func checkPhoneEmpty(_ phone: String?) -> String? {
        guard let p = phone else {
            
            return nil
        }

        return p
    }
    
    // 手机号格式校验
    func phoneFormat(_ phone: String) -> Bool {
        if phone.characters.count == 11 {
            return true
        }
        return false
    }
    
    // 错误提示
    func showErrorTips(_ errorInfo: String, _ title: String, _ tip: String){
        let alertView = SCLAlertView()
        alertView.addButton(title, action: {})
        alertView.showError("提示", subTitle: errorInfo)
    }
    
    //计时器事件
    func updateTime() -> Void {
        
        remainingSeconds -= 1
    }
    
    // 连接后台校验验证码的正确性
    func codeIsTrueLinkServer() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.AppChenkPhone(phoneTextField.text!, code: verifyCodeTextField.text!, success: { [weak self](test) in
            
            if self!.phoneTextField.isFirstResponder {
               self?.phoneTextField.resignFirstResponder()
            }
            if self!.verifyCodeTextField.isFirstResponder {
               self?.verifyCodeTextField.resignFirstResponder()
            }
           
            
            MBProgressHUD.hide(for:  self!.view, animated: true)
            let installInfoVC = RNInstallerInfoViewController(phoneNum: self!.phoneTextField.text!)
            self!.navigationController?.pushViewController(installInfoVC, animated: true)
            
            }, failure: { (error) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("错误提示", subTitle: error.localizedDescription)
        })

    }
    
    func submitAction(){
       

//        let installInfoVC = RNInstallerInfoViewController(phoneNum: self.phoneTextField.text!)
//        self.navigationController?.pushViewController(installInfoVC, animated: true)
        // 检验验证码是否正确
        // 1. 校验非空
        guard checkIsEmpty() else {
            return
        }
        // 2.接口验证码是否正确
       codeIsTrueLinkServer()
    }
}

// MARK: - event response

extension RNInstallMachineViewController {
    
    // 返回按钮事件
    final func disMissBtn(){
        
        _ =  self.navigationController?.popViewController(animated: true)
        
    }

    
}

extension RNInstallMachineViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == phoneTextField {
            verifyCodeTextField.becomeFirstResponder()
        }
        
        if textField == verifyCodeTextField {
            // 检验验证码是否正确
            // 1. 校验非空
            guard checkIsEmpty() else {
                return true
            }
            // 2.接口验证码是否正确
           codeIsTrueLinkServer()
        }
        
        return true
    }
}
