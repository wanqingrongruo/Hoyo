//
//  LoginAndRegisterViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
//import IQKeyboardManager

enum LoginStateEnum:Int {
    case login=0
    case register1=1
    case register2=2
    case register3=3
}
class LoginAndRegisterViewController: UIViewController,UITextFieldDelegate {
    
   // var  returnKeyHandler: IQKeyboardReturnKeyHandler? = nil //键盘管理
    
    
    //视图类
    var loginFooterView:LoginFooterView?
    var registFooterView1:RegistFooterView1?
    var registFooterView2:RegistFooterView2?
    var registFooterView3:RegistFooterView3?
    @IBOutlet weak var bottomImgOfLogin: UIImageView!
    @IBOutlet weak var bottomImgOfRegister: UIImageView!
    @IBOutlet weak var footerViewContainer: UIView!
    @IBAction func loginOrRegistButtonClick(_ sender: UIButton) {
        print(sender.tag)
        currentLoginState = (sender.tag==1) ? .login:.register1
    }
    
    /// 变量
    var firstAppear=true//是不是第一次打开
    /// 视图类
    var guardView:UIView!//首次登录导航视图
    var loginView:UIView!//登录视图
    var registView:UIView!//注册视图
    var currentLoginState = LoginStateEnum.login{
        didSet{
            loginFooterView?.isHidden = (currentLoginState == .login) ? false:true
            registFooterView1?.isHidden = (currentLoginState == .register1) ? false:true
            registFooterView2?.isHidden = (currentLoginState == .register2) ? false:true
            registFooterView3?.isHidden = (currentLoginState == .register3) ? false:true
            bottomImgOfLogin.isHidden=(currentLoginState == .login) ? false:true
            bottomImgOfRegister.isHidden=(currentLoginState != .login) ? false:true
            switch currentLoginState {
            case .login:
                print("Login")
            case .register1:
                print("Register1")
            case .register2:
                print("Register2")
            default:
                print("Register3")
                break
            }
        }
    }
    
    //倒计时剩余的时间
    var remainingSeconds = 0{
        
        willSet{
            
            registFooterView2?.timeLabel.text = String(newValue)
            
            if newValue <= 0 {
                
                registFooterView2?.timeLabel.text = String(60)
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
                
            }else
            {
                countDownTimer?.invalidate()
                countDownTimer = nil
                
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化视图
        loginFooterView=Bundle.main.loadNibNamed("LoginFooterView", owner: nil, options: nil)?.last as? LoginFooterView
        registFooterView1=Bundle.main.loadNibNamed("RegistFooterView1", owner: nil, options: nil)?.last as? RegistFooterView1
        registFooterView2=Bundle.main.loadNibNamed("RegistFooterView2", owner: nil, options: nil)?.last as? RegistFooterView2
        registFooterView3=Bundle.main.loadNibNamed("RegistFooterView3", owner: nil, options: nil)?.last as? RegistFooterView3
        loginFooterView?.phoneTextField.delegate=self
        loginFooterView?.passWordTextField.delegate=self
        registFooterView1?.phoneTextField.delegate=self
        registFooterView2?.codeTextField.delegate=self
        registFooterView3?.nameTextField.delegate=self
        registFooterView3?.nameTextField.returnKeyType = UIReturnKeyType.next
        registFooterView3?.IDCardTextField.delegate=self
        registFooterView3?.IDCardTextField.returnKeyType = UIReturnKeyType.next
        registFooterView3?.passWordTextField.delegate=self
        registFooterView3?.passWordTextField.returnKeyType = UIReturnKeyType.next
        registFooterView3?.invitationCodeTextField.delegate=self
        registFooterView3?.invitationCodeTextField.returnKeyType = UIReturnKeyType.done
    
        loginFooterView?.foregetPassWordButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        loginFooterView?.loginButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        registFooterView1?.nextButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        registFooterView1?.agreeImgButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        registFooterView1?.agreeTextButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        registFooterView2?.nextButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        registFooterView3?.nextButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        footerViewContainer.addSubview(loginFooterView!)
        footerViewContainer.addSubview(registFooterView1!)
        footerViewContainer.addSubview(registFooterView2!)
        footerViewContainer.addSubview(registFooterView3!)
        loginFooterView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(footerViewContainer).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        registFooterView1?.snp.makeConstraints({ (make) in
            make.edges.equalTo(footerViewContainer).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        registFooterView2?.snp.makeConstraints({ (make) in
            make.edges.equalTo(footerViewContainer).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        registFooterView3?.snp.makeConstraints({ (make) in
            make.edges.equalTo(footerViewContainer).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        currentLoginState = .login
        
        //本地保存账号密码时显示
        if  let username = UserDefaults.standard.value(forKey: "UserName") as? String {
            loginFooterView?.phoneTextField.text = username
        }
        if  let passwd = UserDefaults.standard.value(forKey: "PassWord") as? String {
            loginFooterView?.passWordTextField.text = passwd
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        IQKeyboardManager.sharedManager().enable = true
//        IQKeyboardManager.sharedManager().enableAutoToolbar = false
//        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = true
//        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
//        returnKeyHandler =  IQKeyboardReturnKeyHandler(viewController: self)
//        returnKeyHandler!.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        IQKeyboardManager.sharedManager().enable = false
//        IQKeyboardManager.sharedManager().enableAutoToolbar = false
//        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = false
//        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = false
//        returnKeyHandler = nil
    }
    
    
    fileprivate var TmpToken:String?//注册时会用到
    func buttonClick(_ button:UIButton){
        switch button.tag {
        case 1://登录页面：忘记密码
            let forGetPassword = ForGetPassowViewController(nibName: "ForGetPassowViewController", bundle: nil)
            
            let forGetPasswordNav = UINavigationController(rootViewController: forGetPassword)
            forGetPasswordNav.setNavigationBarHidden(true, animated: false)
            self.present(forGetPasswordNav, animated: true, completion: nil);
        case 2://登录页面：登录
            if checkTel(( loginFooterView?.phoneTextField.text)! as NSString) {
                if ((loginFooterView?.passWordTextField.text!)!  as NSString).length == 0  {
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("错误提示", subTitle: "密码不能为空")
                    
                }
                else{
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    User.loginWithPhone((loginFooterView?.phoneTextField.text)!, password: (loginFooterView?.passWordTextField.text)!, success: {
                        [weak self](user) in
                        User.currentUser = user
                        if let strongSelf=self{
                            MBProgressHUD.hide(for: strongSelf.view, animated: true)
                            
                            strongSelf.presentMainViewController()
                        }
                        
                        }, failure: { [weak self](error) in
                            print(error)
                            MBProgressHUD.hide(for: self!.view, animated: true)
                            let alertView=SCLAlertView()
                            alertView.addButton("ok", action: {})
                            alertView.showError("错误提示", subTitle: error.localizedDescription)
                        })
                    
                }
            }else
            {
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: "您输入手机号有误，请重新输入")
            }
            
        case 3://注册页面一：下一步
            if checkTel((registFooterView1?.phoneTextField.text!)! as NSString) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                User.SendPhoneCode((registFooterView1?.phoneTextField.text!)!,order:"register",success: { [weak self] in
                    if let strongSelf=self{
                        MBProgressHUD.hide(for: strongSelf.view, animated: true)
                        strongSelf.currentLoginState = .register2
                        strongSelf.registFooterView2?.phoneTextField.text=strongSelf.registFooterView1?.phoneTextField.text
                        
                        //启动计时器
                        self!.remainingSeconds = 60
                        self!.isCounting = true
                    }
                    }, failure: { [weak self](error) in
                        print(error)
                        MBProgressHUD.hide(for: self!.view, animated: true)
                        let alertView=SCLAlertView()
                        alertView.addButton("ok", action: {})
                        alertView.showError("错误提示", subTitle: error.localizedDescription)
                    })
            }else
            {
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: "手机号格式不正确，请重新输入")
            }
            
        case 4://注册页面一：小对号图标
            print("小对号图标")
        case 5://注册页面一：同意浩优服务家协议
            let tmpUrl = (NetworkManager.defaultManager?.URL.object(forKey: "Agreements"))! as! String
            
            let urlContrller = WeiXinURLViewController(Url: tmpUrl, Title: "浩优服务家协议")
            self.present(urlContrller, animated: true, completion: nil)
            print("同意浩优服务家协议")
        case 6://注册页面二：下一步
            MBProgressHUD.showAdded(to: self.view, animated: true)
            User.AppChenkPhone((registFooterView2?.phoneTextField.text!)!, code: (registFooterView2?.codeTextField.text!)!, success: { [weak self](tmpToken) in
                if let strongSelf=self{
                    MBProgressHUD.hide(for: strongSelf.view, animated: true)
                    strongSelf.currentLoginState = .register3
                    strongSelf.TmpToken=tmpToken
                    
                }
                }, failure: { [weak self](error) in
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("错误提示", subTitle: error.localizedDescription)
                })
            
        case 7://注册页面三：下一步
            
            let tmpName = registFooterView3?.nameTextField.text!
            let tmpIDCard = registFooterView3?.IDCardTextField.text!
            let tmppassWord = registFooterView3?.passWordTextField.text!
            let inviteCode = registFooterView3?.invitationCodeTextField.text
            MBProgressHUD.showAdded(to: self.view, animated: true)
            User.AppRegister(TmpToken!,realname: tmpName!, cardid: tmpIDCard!, password: tmppassWord!, inviteCode: inviteCode, success: { [weak self](user) in
                MBProgressHUD.hide(for: self!.view, animated: true)
                User.currentUser = user
                let authController = AuthenticationController(dissCall: {
                    [weak self] in
                    self!.presentMainViewController()
                    })
                self!.present(authController, animated: true, completion: nil)
                }, failure: { [weak self](error) in
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("错误提示", subTitle: error.localizedDescription)
                })
            
        default:
            break
        }
    }
    
    //计时器事件
    func updateTime() -> Void {
        
        remainingSeconds -= 1
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppear {
            firstAppear = false
            User.loginWithLocalUserInfo(
                success: {
                    [weak self] user in
                    User.currentUser = user
                    //                    print(JPUSHService.registrationID())
                    //                    if JPUSHService.registrationID() != nil {
                    //                        User.BingJgNotifyId(JPUSHService.registrationID(), success: {
                    //                            print("绑定极光通知成功")    
                    //                        }) { (error:NSError) in
                    //                            print("极光错误:"+"\(error)")
                    //                        }
                    //                    }
                    self?.presentMainViewController()
                },
                failure: nil)
        }
    }
    //获取用户信息，然后呈现主视图
    func presentMainViewController() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.GetCurrentUserInfo({ [weak self](user) in
            MBProgressHUD.hide(for: self!.view, animated: true)
            User.currentUser=user
            appDelegate.mainViewController = MainViewController()
            appDelegate.mainViewController.modalTransitionStyle = .crossDissolve
            self!.present(appDelegate.mainViewController, animated: true, completion: nil)
        }) { [weak self](error) in
            MBProgressHUD.hide(for: self!.view, animated: true)
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("错误提示", subTitle: error.localizedDescription)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if [1,3,4,7].contains(textField.tag) && !string.isAllNumber {
            return false
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField != registFooterView3?.invitationCodeTextField {
            
            if textField == registFooterView1?.phoneTextField || textField == registFooterView2?.codeTextField || textField == loginFooterView?.phoneTextField || textField == loginFooterView?.passWordTextField{
                textField.resignFirstResponder()
            }else{
                
                if textField == registFooterView3?.nameTextField {
                    registFooterView3?.IDCardTextField.becomeFirstResponder()
                }
                if textField == registFooterView3?.IDCardTextField {
                    registFooterView3?.passWordTextField.becomeFirstResponder()
                }
                
                if textField == registFooterView3?.passWordTextField {
                    registFooterView3?.invitationCodeTextField.becomeFirstResponder()
                }
            }
            
        }else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience  init() {
        var nibNameOrNil = String?("LoginAndRegisterViewController")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
