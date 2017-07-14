//
//  GetMoneyViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/5.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager

class GetMoneyViewController: UIViewController, UITextFieldDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    var scrollView: UIScrollView!
    var backView: UIView!
    var cardLabel: UILabel!
    var selectCardButton: UIButton!
    var getTitleLabel: UILabel!
    var moneySignLabel: UILabel!
    var getMoneyTextField: UITextField!
    var lineView: UIView!
    var leftMoneyLabel: UILabel!
    var allGetButton: UIButton!
    var getMoneyButton: UIButton!
    
    //加约束的一些固定数据
    let horizontalSpace = 20
    let verticalSpace = 0
    let height = 40
    
    
    var dataSource = [String]()//数据源
    var dataSource02 = [BankModel]() //存放银行卡的model
    var currentModel:BankModel? //选中的model
    var currentBank:String? //选择中银行,,传递到下个界面
    var myBalance:Double = 0.00{ //我的零钱余额
        
        didSet{
            
            leftMoneyLabel.text = String(format: "零钱余额￥%.2lf,",myBalance)
            let titleSize = (leftMoneyLabel.text! as NSString).size(attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15)])
            leftMoneyLabel.snp.makeConstraints { (make) in
                make.width.equalTo(titleSize.width+5)
            }
        }
    }
    
    var popoverView: PopoverView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "提现"
        view.backgroundColor = UIColor(red: 40/255.0, green: 56/255.0, blue: 82/255.0, alpha: 1.0)
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        setupUI()
        //下载银行卡列表
        downloadBankListFromServer()
        //获取账户余额
        downloadGetMoneyDetail()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardReturnKeyHandler.init().lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        
        // navigationController?.navigationBarHidden = true
    }
    
    deinit{
        
        getMoneyTextField.resignFirstResponder()
        
        if let pop = popoverView {
            pop.hide()
        }
    }
    
}

// MARK: - 界面

extension GetMoneyViewController{
    
    func setupUI() -> Void {
        scrollView = UIScrollView()
        scrollView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        let contrainerView = UIView()
        contrainerView.backgroundColor = UIColor.white
        scrollView.addSubview(contrainerView)
        contrainerView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(HEIGHT_SCREEN+10)
        }
        
        
        backView = UIView()
        backView.backgroundColor = UIColor.white
        contrainerView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpace)
            make.leading.equalTo(view.snp.leading).offset(horizontalSpace)
            make.trailing.equalTo(view.snp.trailing).offset(-horizontalSpace)
            make.height.equalTo(4*height+1)
        }
        
        cardLabel = UILabel()
        cardLabel.text = "到账银行卡"
        cardLabel.textColor = UIColor.black
        cardLabel.textAlignment = NSTextAlignment.left
        cardLabel.font = UIFont.systemFont(ofSize: 15)
        backView.addSubview(cardLabel)
        cardLabel.snp.makeConstraints { (make) in
            make.top.equalTo(verticalSpace)
            make.leading.equalTo(horizontalSpace)
            make.width.equalTo(80)
            make.height.equalTo(height)
        }
        
        selectCardButton = UIButton()
        selectCardButton.setTitle("添加银行卡", for: UIControlState())
        selectCardButton.setTitleColor(COLORRGBA(0, g: 122, b: 255, a: 1), for: UIControlState())
        selectCardButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        selectCardButton.titleLabel?.textAlignment = NSTextAlignment.center
        selectCardButton.addTarget(self, action: #selector(selectBankCard(_:)), for: UIControlEvents.touchUpInside)
        backView.addSubview(selectCardButton)
        selectCardButton.snp.makeConstraints { (make) in
            make.leading.equalTo(cardLabel.snp.trailing).offset(0)
            make.centerY.equalTo(cardLabel.snp.centerY)
            make.height.equalTo(cardLabel.snp.height)
            make.trailing.greaterThanOrEqualTo(10)
        }
        
        getTitleLabel = UILabel()
        getTitleLabel.text = "提现金额:"
        getTitleLabel.textColor = UIColor.black
        getTitleLabel.textAlignment = NSTextAlignment.left
        getTitleLabel.font = UIFont.systemFont(ofSize: 15)
        backView.addSubview(getTitleLabel)
        getTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(cardLabel.snp.bottom).offset(0)
            make.leading.equalTo(horizontalSpace)
            make.trailing.equalTo(0)
            make.height.equalTo(height)
        }
        
        moneySignLabel = UILabel()
        moneySignLabel.text = "￥"
        moneySignLabel.textColor = UIColor.black
        moneySignLabel.textAlignment = NSTextAlignment.left
        moneySignLabel.font = UIFont.systemFont(ofSize: 20)
        backView.addSubview(moneySignLabel)
        moneySignLabel.snp.makeConstraints { (make) in
            make.top.equalTo(getTitleLabel.snp.bottom).offset(0)
            make.leading.equalTo(horizontalSpace)
            make.width.equalTo(40)
            make.height.equalTo(height)
        }
        
        getMoneyTextField = UITextField()
        getMoneyTextField.delegate = self
        getMoneyTextField.textColor = COLORRGBA(0, g: 122, b: 255, a: 1)
        getMoneyTextField.placeholder = "请输入提现金额(元)"
        getMoneyTextField.keyboardType = UIKeyboardType.decimalPad
        getMoneyTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        getMoneyTextField.returnKeyType = UIReturnKeyType.done
        backView.addSubview(getMoneyTextField)
        getMoneyTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(moneySignLabel.snp.trailing).offset(0)
            make.centerY.equalTo(moneySignLabel.snp.centerY)
            make.height.equalTo(moneySignLabel.snp.height)
            make.trailing.equalTo(-20)
        }
        
        lineView = UIView()
        lineView.backgroundColor = COLORRGBA(239, g: 239, b: 239, a: 1)
        backView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(moneySignLabel.snp.bottom).offset(0)
            make.leading.equalTo(horizontalSpace+20)
            make.height.equalTo(1)
            make.trailing.equalTo(-horizontalSpace-20)
        }
        
        leftMoneyLabel = UILabel()
        leftMoneyLabel.text = "零钱余额￥0.00,"
        leftMoneyLabel.textColor = UIColor.black
        leftMoneyLabel.textAlignment = NSTextAlignment.left
        leftMoneyLabel.font = UIFont.systemFont(ofSize: 15)
        backView.addSubview(leftMoneyLabel)
        leftMoneyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(0)
            make.leading.equalTo(20)
            make.height.equalTo(height)
        }
        
        allGetButton = UIButton()
        allGetButton.setTitle("全部提现", for: UIControlState())
        allGetButton.setTitleColor(COLORRGBA(0, g: 122, b: 255, a: 1), for: UIControlState())
        allGetButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        allGetButton.titleLabel?.textAlignment = NSTextAlignment.left
        allGetButton.addTarget(self, action: #selector(allGetAction(_:)), for: UIControlEvents.touchUpInside)
        backView.addSubview(allGetButton)
        allGetButton.snp.makeConstraints { (make) in
            make.leading.equalTo(leftMoneyLabel.snp.trailing).offset(0)
            make.centerY.equalTo(leftMoneyLabel.snp.centerY)
            make.height.equalTo(leftMoneyLabel.snp.height)
            make.width.equalTo(80)
        }
        
        
        getMoneyButton = UIButton()
        getMoneyButton.setTitle("提现", for: UIControlState())
        getMoneyButton.setTitleColor(COLORRGBA(255, g: 255, b: 255, a: 1), for: UIControlState())
        getMoneyButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        getMoneyButton.backgroundColor = UIColor.gray
        getMoneyButton.isEnabled = true // 初始状态不可点击
        getMoneyButton.titleLabel?.textAlignment = NSTextAlignment.center
        getMoneyButton.addTarget(self, action: #selector(getMoneyAction(_:)), for: UIControlEvents.touchUpInside)
        contrainerView.addSubview(getMoneyButton)
        getMoneyButton.snp.makeConstraints { (make) in
            make.top.equalTo(backView.snp.bottom).offset(40)
            make.leading.equalTo(contrainerView.snp.leading).offset(horizontalSpace)
            make.height.equalTo(40)
            make.trailing.equalTo(contrainerView.snp.trailing).offset(-horizontalSpace)
            
        }
        getMoneyButton.layer.cornerRadius = 5
        
    }
}

// MARK: - event reponse

extension GetMoneyViewController{
    
    //左边按钮
    func disMissBtn(){
        
        getMoneyTextField.resignFirstResponder()
        
        if let pop = popoverView {
            pop.hide()
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    /**
     选择银行卡--按钮事件
     
     - parameter sender: 按钮
     */
    func selectBankCard(_ sender: UIButton) -> Void {
        
        getMoneyTextField.resignFirstResponder()
        
        if dataSource.isEmpty {
            
            //            //跳转添加银行卡页面
            //            let addCar = AddCarViewController()
            //            self.navigationController?.pushViewController(addCar, animated: true)
            
            let addBankVC = RNNewAddBankViewController(nibName: "RNNewAddBankViewController", bundle: nil)
            self.navigationController?.pushViewController(addBankVC, animated: true)
            
        }else{
            
            popoverView = PopoverView()
            popoverView!.menuTitles = dataSource
            weak var weakSelf = self
            popoverView!.show(from: selectCardButton, selected: { (index: Int) in
                weakSelf?.selectCardButton.setTitle(weakSelf?.popoverView!.menuTitles[index] as? String, for: UIControlState())
                weakSelf?.currentModel = weakSelf?.dataSource02[index]
                weakSelf?.currentBank = weakSelf?.popoverView!.menuTitles[index] as? String
            })
        }
        
    }
    
    /**
     全部提现--按钮事件
     
     - parameter sender: 按钮
     */
    func allGetAction(_ sender: UIButton) -> Void {
        //将所有余额全部提现
        getMoneyTextField.text = String(format: "%.2lf",myBalance)
    }
    
    /**
     提现--按钮事件
     
     - parameter sender: 按钮
     */
    func getMoneyAction(_ sender: UIButton) -> Void {
        
        /*校验
         1.校验是否已小数点开头,例如.99,,则体现是自动补0->0.99
         2.校验提现金额是否超过余额
         3.判断是否为空
         */
        
        if getMoneyTextField.text!.isEmpty {
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("错误提示", subTitle: "提现金额不能为空")
            
        }else{
            if getMoneyTextField.text!.hasPrefix(".") {//是否已"."开头
                
                let tmp = (("0" + getMoneyTextField.text!) as NSString).doubleValue
                getMoneyTextField.text = String(format: "%.2f",tmp)
                if (getMoneyTextField.text! as NSString).doubleValue > myBalance {
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("错误提示", subTitle: "余额不足")
                }
                else if (getMoneyTextField.text! as NSString).doubleValue <= 0{
                    
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("错误提示", subTitle: "提现金额不能为0")
                    
                }
                else{
                    
                    self.view.endEditing(true)
                    weak var weakSelf = self
                    guard let bankid = currentModel?.bankId else {
                        return
                    }
                    guard let money = getMoneyTextField.text, money != "" else {
                        return
                    }
                    User.submitInfoToGetMoney(["blankid": bankid,"WDMoney": money], success: {
                        //跳转到下个界面
                        
                        // print("yyyyyyyyyyyyyyyyyy")
                        
                        let getMoneyDetailVC = GetMoneyDetailTableViewController()
                        getMoneyDetailVC.bankInfo = weakSelf?.currentBank
                        getMoneyDetailVC.getAmount = weakSelf?.getMoneyTextField.text
                        self.navigationController?.pushViewController(getMoneyDetailVC, animated: true)
                        
                    }, failure: { (error) in
                        print(error.localizedDescription)
                    })
                }
                
            }else if getMoneyTextField.text!.hasSuffix("."){
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: "提现金额不能以小数点结尾")
                
            }
            else if (getMoneyTextField.text! as NSString).doubleValue <= 0{
                
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: "提现金额不能为0")
                
            }
            else if (getMoneyTextField.text! as NSString).doubleValue > myBalance{
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("错误提示", subTitle: "余额不足")
            }else{
                self.view.endEditing(true)
                //调用接口提现
                weak var weakSelf = self
                guard let bankid = currentModel?.bankId else {
                    return
                }
                guard let money = getMoneyTextField.text, money != "" else {
                    return
                }
                User.submitInfoToGetMoney(["blankid": bankid,"WDMoney": money], success: {
                    //跳转到下个界面
                    // print("yyyyyyyyyyyyyyyyyy")
                    
                    let getMoneyDetailVC = GetMoneyDetailTableViewController()
                    getMoneyDetailVC.bankInfo = weakSelf?.currentBank
                    getMoneyDetailVC.getAmount = weakSelf?.getMoneyTextField.text
                    self.navigationController?.pushViewController(getMoneyDetailVC, animated: true)
                    
                }, failure: { (error) in
                    let alertView = SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("提示", subTitle: error.localizedDescription)
                })
            }
            
        }
    }
    
}


// MARK: - download data

extension GetMoneyViewController{
    
    //获取银行卡列表
    func downloadBankListFromServer() -> Void {
        
        weak var weakSelf = self
        User.GetOwenBindBlankCard({ (tmpArr) in
            
            for model in tmpArr{
                weakSelf?.dataSource02.append(model)
                weakSelf?.dataSource.append(weakSelf!.linkBankInfo(model))
            }
            
            //显示数据
            weakSelf?.showData()
            
            
        }){ (error) in
            
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
        }
        
    }
    
    
    //获取账户余额
    func downloadGetMoneyDetail() -> Void {
        
        weak var weakSelf = self
        User.GetOwenMoney({ (model) in
            //显示余额
            if let bla = model.balance, let tmp = Double(bla){
                weakSelf?.myBalance = tmp
            }else{
                weakSelf?.myBalance = 0.0
            }
            
            
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)        }
    }
}

// MARK: - 显示数据

extension GetMoneyViewController{
    
    /**
     显示控件上的数据
     */
    func showData() -> Void {
        
        
        if dataSource.isEmpty {
            selectCardButton.setTitle("添加银行卡", for: UIControlState())
            getMoneyButton.backgroundColor = UIColor.gray
            getMoneyButton.isEnabled = false
        }else{
            selectCardButton.setTitle(dataSource.first, for: UIControlState())
            currentModel = dataSource02.first
            currentBank = dataSource.first
            getMoneyButton.backgroundColor = UIColor.orange
            getMoneyButton.isEnabled = true
        }
        
    }
}


// MARK: - 拼接银行卡信息

extension GetMoneyViewController{
    
    func linkBankInfo(_ model:BankModel) -> String {
        // 建设银行 尾号(5555)
        var resultString:String = ""
        resultString += model.bankName!
        resultString += "   "
        
        var tempStr:String = "尾号("
        var count = 0
        for item in (model.cardId?.characters)! {
            count += 1
            if count > ((model.cardId?.characters.count)! - 4) {
                tempStr.append(item)
            }
        }
        tempStr += ")"
        
        resultString += tempStr
        
        return resultString
    }
}

// MARK: - UITextFieldDelegate

extension GetMoneyViewController{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //限制输入框只能输入数字(最多两位小数)
        return  textField.moneyFormatCheck(textField.text!, range: range, replacementString: string, remian: 2)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getMoneyTextField.resignFirstResponder()
        return true
    }
    
}


//extension GetMoneyViewController:UINavigationControllerDelegate, UIGestureRecognizerDelegate{
//
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        // 当导航栈中的视图控制器熟练小于等于1时,忽略 pop 手势
//        if navigationController?.viewControllers.count <= 1{
//            return false
//        }
//
//        getMoneyTextField.resignFirstResponder()
//
//        if let pop = popoverView {
//            pop.hide()
//        }
//
//        return true
//    }
//}


