//
//  FillBankCardMessageController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 2/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class FillBankCardMessageController: UIViewController {
    
   
    @IBOutlet weak var bankTypeTextField: UITextField!
    
    @IBOutlet weak var bankPhoneTextField: UITextField!
    
    @IBOutlet weak var confirmCodeTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func sendCode(_ sender: UIButton) {
        
        if (bankPhoneTextField.text! as NSString).length == 11{
            
            //调用发送验证码接口
            User.SendPhoneCodeForBankCard(bankPhoneTextField.text!, order: "BindCard", success: { [weak self] in
                //启动计时器
                self!.remainingSeconds = 60
                self!.isCounting = true
                
            }) { (error) in
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("错误提示", subTitle: error.localizedDescription)
                
            }
        }else{
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle:  "手机号码格式不正确")
        }
    }
    
    @IBAction func bindingAction(_ sender: UIButton) {
        
        
        if (bankTypeTextField.text! as NSString).length == 0{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle:  "卡类型不能为空")
        }else if (bankTypeTextField.text! !=  "储蓄卡"){
            
            if (bankTypeTextField.text! != "信用卡"){
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("错误提示", subTitle:  "请填写储蓄卡或信用卡")
            }else{
                
                //立即绑定
                bingdingBankCard()
            }
        }else if (bankPhoneTextField.text! as NSString).length == 11{
            
            //立即绑定
            bingdingBankCard()
            
        }else{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("错误提示", subTitle:  "请填写储蓄卡或信用卡")
        }
        
    }
    
    //倒计时剩余的时间
    var remainingSeconds = 0{
        
        willSet{
            
            confirmButton.setTitle("(\(newValue)s)", for: UIControlState())
            
            if newValue <= 0 {
                confirmButton.setTitle("重新获取", for: UIControlState())
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
                
                confirmButton.backgroundColor = UIColor.gray
            }
            else
            {
                countDownTimer?.invalidate()
                countDownTimer = nil
                
                confirmButton.backgroundColor = UIColor.brown
            }
            
            confirmButton.isEnabled = !newValue
        }
    }
    
    var realName:String?
    var bankNumber:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "填写银行卡信息"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))

        
        setupTextFiled()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        // IQKeyboardReturnKeyHandler.init().lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
         navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        
        //等整体导航栏改完之后,需要删除
      //  navigationController?.navigationBarHidden = true
        
    }

   
    
    // MARK - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    convenience  init() {
        var nibNameOrNil = String?("FillBankCardMessageController")
        
        //考虑到xib文件可能不存在或被删，故加入判断
        
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
            
        {
            nibNameOrNil = nil
            
        }
        
        self.init(nibName: nibNameOrNil, bundle: nil)
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }


}

// MARK: - TextFiled

extension FillBankCardMessageController:UITextFieldDelegate{
    
    //初始化TextField
    func setupTextFiled() -> Void {
        bankTypeTextField.placeholder = "储蓄卡或信用卡"
        bankTypeTextField.delegate = self
        confirmCodeTextField.keyboardType = UIKeyboardType.default
        bankTypeTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        bankPhoneTextField.placeholder = "银行预留手机号码"
        bankPhoneTextField.delegate = self
        bankPhoneTextField.keyboardType = UIKeyboardType.numberPad
        bankPhoneTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        
    }
}

// MARK: - 点击按钮获取验证码

extension FillBankCardMessageController{
    
    //计时器事件
    func updateTime() -> Void {
        
        remainingSeconds -= 1
    }
}

// MARK: - 网络请求

extension FillBankCardMessageController{
    func bingdingBankCard() -> Void {
        //绑定验证
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.BindNewBlankCard(["realname":realName!,"cardType":bankTypeTextField.text!,"cardid":bankNumber!,"cardphone":bankPhoneTextField.text!,"code":confirmCodeTextField.text!], success: { [weak self] in
            //验证成功跳转回navigation第二层(所有绑定的银行卡界面/提现界面)
            
            MBProgressHUD.hide(for: self!.view, animated: true)
            if self!.navigationController?.viewControllers.count >= 2 {
                let viewController = self!.navigationController?.viewControllers[1]
                
                //这里强制解包可能存在问题
                if (viewController!.isMember(of: BoundBankCardViewController.self)){
                    
                    let vc = viewController as? BoundBankCardViewController
                    vc!.downloadDataFromServer()
                    _ = self!.navigationController?.popToViewController(vc!, animated: true)
                }else if (viewController!.isMember(of: GetMoneyViewController.self)){
                    let vc = viewController as? GetMoneyViewController
                    vc!.downloadBankListFromServer()
                    _ = self!.navigationController?.popToViewController(vc!, animated: true)
                }
            }
            
            //            for controller in (self!.navigationController?.viewControllers)!{
            //
            //                if controller.isKindOfClass(BoundBankCardViewController){
            //
            //                    let vc = controller as? BoundBankCardViewController
            //                    vc!.downloadDataFromServer()
            //                    self!.navigationController?.popToViewController(vc!, animated: true)
            //                }
            //            }
            
            }, failure: { [weak self](error) in
                
                MBProgressHUD.hide(for: self!.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("错误提示", subTitle: error.localizedDescription)
                
            })
        
    }
}


// MARK: - event response

extension FillBankCardMessageController{
    
    //左边按钮
    func disMissBtn(){
       _ =  navigationController?.popViewController(animated: true)
    }
    
}


