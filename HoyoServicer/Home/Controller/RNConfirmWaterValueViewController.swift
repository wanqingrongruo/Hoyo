//
//  RNConfirmWaterValueViewController.swift
//  HoyoServicer
//
//  Created by 郑文祥 on 2017/6/16.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD

class RNConfirmWaterValueViewController: UIViewController {
    
    var orderDetail:OrderDetail? // 订单详情--从上个界面带来
    var deviceInfo: ROWaterPurufier? // IO
    
    var isRemainDays = true  // 是否有剩余水值, 有则不用调取接口, 否则调取礼品卡接口获取信息
    
    var callBack: (Bool)->()
    
    var phone: String = ""
    var mac: String = ""
    var remainValue = ""

    @IBOutlet weak var leftWaterValueLabel: UILabel!
    @IBOutlet weak var recoverValueLabel: UILabel!
    @IBOutlet weak var usernamLabel: UILabel!
    @IBOutlet weak var pthoneTextField: UITextField!
    @IBOutlet weak var yTDSLabel: UILabel!
    @IBOutlet weak var hTDSLabel: UILabel!
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBAction func confirmAction(_ sender: UIButton) {
        
        guard let newPhone = self.pthoneTextField.text, newPhone != "", newPhone.characters.count == 11 else{
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "手机号码格式不正确")
            return
        }
        
        self.phone = newPhone
        
        if isRemainDays {
            // 直接返回
            
            self.callBack(true)
            _ = self.navigationController?.popViewController(animated: true)
            
        }else{
            // 上传数据后返回
            submit()
        }
        
    }
    
    @IBAction func refreshAction(_ sender: UIButton) {
        
        if let newPhone = self.pthoneTextField.text, newPhone != "", newPhone.characters.count == 11, phone != newPhone {
            self.phone = newPhone
            getData(phone: newPhone, mac: mac)
        }
        
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, callBack:@escaping (Bool) -> ()) {
        
        self.callBack = callBack
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        self.title = "确认完成"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 5
        refreshButton.layer.masksToBounds = true
        refreshButton.layer.cornerRadius = 5
        
        pthoneTextField.delegate = self
        
        getConditions()
        
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

// MARK: - private methods

extension RNConfirmWaterValueViewController {
    
    func getConditions() {
        
        guard let deviceInfo = deviceInfo else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到设备信息")
            return
        }
        guard let phone = orderDetail?.mobile else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到用户信息")
            return
        }
        
        guard let mac = deviceInfo.identifier else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "未获取到设备 mac 地址")
            return
        }
        
        self.phone = phone
        self.mac = mac
        
        let remainDays = Int(deviceInfo.settingInfo.waterRemindDays)
        
        if remainDays <= 0 {
            
             isRemainDays = false
             self.remainValue = String(describing: 0)
            
        }else{
            isRemainDays = true
            self.remainValue = String(describing: remainDays)
            
        }
        
        // 调用接口
        getData(phone: phone, mac: mac)
        
    }
    
    func showInfo(mac: String, remainDays: String, recoverValue: String, phone: String) {
        
        leftWaterValueLabel.text = remainDays + "天"
        recoverValueLabel.text = recoverValue + "天"
        usernamLabel.text = orderDetail?.nickname
        pthoneTextField.text = phone
        
        if let yTDS = deviceInfo?.waterInfo.tds1{
            yTDSLabel.text = String(describing: yTDS)
        }else{
            yTDSLabel.text = "无"
        }
        
        if let hTDS = deviceInfo?.waterInfo.tds2{
            hTDSLabel.text = String(describing: hTDS)
        }else{
            hTDSLabel.text = "无"
        }
        
        macLabel.text = mac
        
    }
    
    
    func getData(phone: String, mac: String){
        
        MBProgressHUD.showAdded(to: view, animated: true)
        User.GetWaterValueInfo(phone, success: { (waterValue) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showInfo(mac: mac, remainDays: self.remainValue, recoverValue: waterValue, phone: phone)
            
        }) { (error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
    }
    
    func submit() {
        
        MBProgressHUD.showAdded(to: view, animated: true)
        User.CreateWaterCard(self.phone, mac: self.mac, success: { 
            //
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {
                self.callBack(true)
                _ = self.navigationController?.popViewController(animated: true)

            })
            alertView.showSuccess("提示", subTitle: "水值修改成功")
            
        }) { (error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
        
    }
}


// MARK: - UITextFieldDelegate

extension RNConfirmWaterValueViewController: UITextFieldDelegate {
    
}

// MARK: - event response

extension RNConfirmWaterValueViewController {
    
    func disMissBtn(){
        
        if isRemainDays {
            self.callBack(true)
        }else{
            self.callBack(false)
        }
        _ = self.navigationController?.popViewController(animated: true)
        
    }
}
