//
//  RNInstallerInfoViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/3/15.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD
import SwiftyJSON

class RNInstallerInfoViewController: UIViewController {
    
    var phoneNumber: String
    
    var tableView: UITableView!
    
    var myCell: RNInstallInfoTableViewCell!
    
    var params = [String: Any]() //参数列表
    
    var QRTag = 0 // 扫描哪个二维码
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "填写信息"
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        view.backgroundColor = UIColor.white
        
        initView()
        tableView.updateConstraints()
    }
    
    init( phoneNum: String) {
        self.phoneNumber = phoneNum
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

extension RNInstallerInfoViewController {
    
    func initView(){
        
        self.tableView=UITableView(frame:CGRect(x: 0, y: 0, width: WIDTH_SCREEN,height: HEIGHT_SCREEN-HEIGHT_NavBar),style:UITableViewStyle.plain)
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView.estimatedRowHeight = 660
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView(frame: CGRect.zero )
        self.tableView.register(UINib(nibName:"RNInstallInfoTableViewCell", bundle:nil), forCellReuseIdentifier:"RNInstallInfoTableViewCell")
        self.view.addSubview(self.tableView!)
        
    }
    
    func makeParams() -> Bool {
        guard let name = myCell.nameTextField.text, name != "" else {
            showErrorTips("请输入客户姓名", "确定", "提示")
            return false
        }
        
        guard let phone = myCell.phoneNumLabel.text, phone != "" else {
            showErrorTips("手机号码为空", "确定", "提示")
            return false
        }
        
        guard let address = myCell.areaLabel.text, address != "" else {
            showErrorTips("请选择地区", "确定", "提示")
            return false
        }
        
        let areas = address.components(separatedBy: " ")
        if areas.count < 3 {
            showErrorTips("地区选择不完整", "确定", "提示")
            return false
        }
        
        guard let detailAddress = myCell.adreessTextField.text, detailAddress != "" else {
            showErrorTips("请输入详细地址", "确定", "提示")
            return false
        }
        
        guard let productID = myCell.productIDTextField.text, productID != "" else {
            showErrorTips("请输入产品ID", "确定", "提示")
            return false
        }
        
        guard let machineID = myCell.machineIDLabel.text, machineID != "" else {
            showErrorTips("请扫描二维码获取机器型号", "确定", "提示")
            return false
        }
        
        guard let IMEIID = myCell.IMEIIDLabel.text, IMEIID != "" else {
            showErrorTips("请扫描二维码获取IMEI号", "确定", "提示")
            return false
        }
        
        guard let installer = myCell.installerTextField.text, installer != "" else {
            showErrorTips("请输入安装人姓名", "确定", "提示")
            return false
        }
        
        params["UserName"] = name
        params["UserPhone"] = phone
        params["Province"] = areas[0]
        params["City"] = areas[1]
        params["District"] = areas[2]
        params["Address"] = detailAddress
        params["ProductID"] = Int(productID)
        params["MachineType"] = machineID
        params["IMEI"] = IMEIID
        params["InstallEngineer"] = installer
        params["InstallNumber"] = "1"
        params["FromSourse"] = "千野"
        params["PayWay"] = "线下支付"
        
        if let optionalPhone = myCell.optionalTextField.text {
            
            if (optionalPhone.characters.count == 11) && optionalPhone.phoneFormatCheck() {
                params["S_UserPhone"] = optionalPhone
            }
        }
        
        if let remarks = myCell.remarkTextView.text {
            if remarks.characters.count > 0 {
                params["Remarks"] = remarks
            }
        }
        
        return true
        
    }
    
    // 错误提示
    func showErrorTips(_ errorInfo: String, _ title: String, _ tip: String){
        let alertView = SCLAlertView()
        alertView.addButton(title, action: {})
        alertView.showError("提示", subTitle: errorInfo)
    }
    
    // 字典转 jsonString
    func dicToJsonString(_ dic: [String: Any]) -> String?{
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        guard let haveData = data else{
            return nil
        }
        var strJson = String(data: haveData, encoding: String.Encoding.utf8)
        
        strJson = strJson?.replacingOccurrences(of: "\n", with: "")
        //strJson = strJson?.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        return strJson
    }

}

// MARK: - event response

extension RNInstallerInfoViewController {
    
    // 返回按钮事件
    func disMissBtn(){
        
        _ =  self.navigationController?.popViewController(animated: true)
        
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSoure

extension RNInstallerInfoViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "RNInstallInfoTableViewCell") as! RNInstallInfoTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        myCell = cell
        cell.delegate = self
        
        cell.phoneNumLabel.text = phoneNumber
        
        return cell
    }
    
}

// MARK: - RNInstallInfoCellDelegate

extension RNInstallerInfoViewController: RNInstallInfoCellDelegate {
    
    func selectAreaInfo() {
        
        let jsonPath = Bundle.main.path(forResource: "china_cities_three_level", ofType: "json")
        let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
        let tmpObject: AnyObject?
        do{
            tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        }
        let adressArray = tmpObject as! NSMutableArray
        var provinceArr = [String]()
        for item in adressArray {
            let str = (item as AnyObject)["name"] as! String
            provinceArr.append(str)
        }
        let selectAreaVC = RNSelectAreaTableViewController(index: 0, data: provinceArr, location: "", selected:"")
        selectAreaVC.delegate = self
        navigationController?.pushViewController(selectAreaVC, animated: true)
    }
    
    func scanQRInfo(tag: Int) {
        //扫描二维码
        // 100-机器码 200-IMEI
        QRTag = tag
        let  scan = OznerScanViewController()
        scan.delegate = self
        self.navigationController?.pushViewController(scan, animated: true)

    }
    
    func confirmInfo() {
        if makeParams() {
            
            if let jsonStr = dicToJsonString(params) {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                User.SubmitInstallInfo(jsonStr: jsonStr, success: { [weak self] in
                    // 提交成功
                    MBProgressHUD.hide(for:  self!.view, animated: true)
                    
                }, failure: { (error) in
                    MBProgressHUD.hide(for:  self.view, animated: true)
                    let alertView = SCLAlertView()
                    alertView.addButton("确定", action: {})
                    alertView.showError("提示", subTitle: error.localizedDescription)

                })
            }else{
                let alertView = SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "参数转换失败")
            }

        }
        
    }
    
    func reloadUI(){
        self.tableView.reloadData()
        
        
    }
}

// MARK: - RNSelectAreaTableViewControllerDelegate

extension RNInstallerInfoViewController: RNSelectAreaTableViewControllerDelegate {
    
    func reloadInstallInfoUI(_ loaction: String) {
        self.myCell.areaLabel.text = loaction // 更新区域信息
    }
}

// MARK: - OznerScanViewControllerDelegate

extension RNInstallerInfoViewController: OznerScanViewControllerDelegate{
    
    // 扫描二维码回调
    func popToSubmitCon(_ result: String) {
        
        switch QRTag {
        case 100:
            myCell.machineIDLabel.text = result
        case 200:
            myCell.IMEIIDLabel.text = result
        default:
            break
        }
        
    }
}


