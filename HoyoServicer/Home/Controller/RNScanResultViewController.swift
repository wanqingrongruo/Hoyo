//
//  RNScanResultViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/19.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MBProgressHUD
import SwiftyJSON

class filterModel: NSObject {
    var index: Int!
    var filterName: String!
    var filterYear: String!
    
}

class RNScanResultViewController: UIViewController {
    
    var typeCode = "" // 型号
    var number = "" // 编号
    
    var tableView: UITableView!
    
    var dataSourceDic = [Int:[RNUserRecordModel]]()
    
    var scanResultCell: RNScanResultTableViewCell?
    var scanResultCell02: RNScanResultTableViewCell02?
    var scanResultCell02_02: RNScanResultTableViewCell02_02?
    var scanResultCell03: RNScanResultTableViewCell03?
    var scanResultCell03_02: RNScanResultTableViewCell03_02?
    var scanResultCell04: RNScanResultTableViewCell04?
    var scanResultCell04_02: RNScanResultTableViewCell04_02?
    var scanResultCell05: RNScanResultTableViewCell05?
    
    var filterSettingCount = 3 // 滤芯设定总共几级
    
    var filterSettingArray = [filterModel]()
    
    var timeAndMaxvol: (CLong?, String?)
    
    var finalParamsDic: NSMutableDictionary? //最终提交的参数字典
    var finalString = "" // 最终提交的 jsonString
    
    lazy var heightForIndex = {  // 高度缓存
        return [IndexPath: CGFloat]()
    }()
    
    var isLinkedBluetooth = false // 是否已经连接上蓝牙并写入了数据 -- 当连接蓝牙成功时改变值为 true
    
    // 已经展示过的 cell 的高度是否存在改变的情况 -- 如果存在,每次在缓存高度的都重复缓存,反之,不重新缓存
    var isChangeForCellHeight = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.title = "智能净水伴侣用户档案"
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(dissBtnAction))
        
        //        var array = [RNUserRecordModel]()
        //        for i in 1...2 {
        //            let model = RNUserRecordModel()
        //            model.isRealData = true
        //            model.name = "数据\(i)"
        //            model.year = "时间\(i)"
        //            array.append(model)
        //        }
//        
//        var array02 = [RNUserRecordModel]()
//        for i in 1...2 {
//            let model = RNUserRecordModel()
//            model.isRealData = true
//            model.name = "日期\(i)"
//            model.year = "滤芯级数\(i)"
//            model.index = i
//            array02.append(model)
//        }
//        
//        var array03 = [RNUserRecordModel]()
//        for i in 1...2 {
//            let model = RNUserRecordModel()
//            model.isRealData = true
//            model.name = "日期\(i)"
//            model.year = "维修内容\(i)"
//            model.index = i
//            array03.append(model)
//        }
//        
//        
//        //  dataSourceDic.updateValue(array, forKey: 1)
//        dataSourceDic[2] = array02
//        dataSourceDic[3] = array03
        
        
        
        initFilterSettingArray()
        
        setupTableView()
        
        getInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    
    func initFilterSettingArray(){
        for i in 1...2{
            let model = filterModel()
            model.index = i
            model.filterName = ""
            model.filterYear = "0"
            filterSettingArray.append(model)
        }
    }
    
    
}

// MARK: - custom methods
extension RNScanResultViewController {
    
    // 常见tableView
    func setupTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-64), style: UITableViewStyle.grouped)
        // tableView.backgroundColor = UIColor.whiteColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "RNScanResultTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell")
        tableView.register(UINib(nibName: "RNScanResultTableViewCell02", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell02")
        tableView.register(UINib(nibName: "RNScanResultTableViewCell02_02", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell02_02")
        tableView.register(UINib(nibName: "RNScanResultTableViewCell03", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell03")
        tableView.register(UINib(nibName: "RNScanResultTableViewCell03_02", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell03_02")
        tableView.register(UINib(nibName: "RNScanResultTableViewCell04", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell04")
        tableView.register(UINib(nibName: "RNScanResultTableViewCell04_02", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell04_02")
        tableView.register(UINib(nibName: "RNScanResultTableViewCell05", bundle: Bundle.main), forCellReuseIdentifier: "RNScanResultTableViewCell05")
        
        tableView.estimatedRowHeight = 600
      //  tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
    }
    
    
    func getInfo(){
        
        guard let currentuser = User.currentUser else{
            return
        }
        
        guard let mobile = currentuser.mobile else{
            return
        }
        let params = ["mobile":mobile, "deviceId": number]
        
         MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
       // manager
        //10.203.1.49
        //test.oznerwater.com
        manager.get("http://hoyo.ozner.net/OznerFamilyService/Handlers/DeviceAppServiceGetInfoHandler.ashx", parameters: params, success: { (operation, responseObject) in
            
             MBProgressHUD.hide(for: UIApplication.shared.keyWindow, animated: true)
            
            let error: NSError? = nil
            let object: AnyObject?
            do{
                object = try! JSONSerialization.jsonObject(with: responseObject as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            }
            if error != nil || object == nil || !(object is NSDictionary) {
                return
            }
            // print(object)
            let state = object?.object(forKey: "IsSuccessed") == nil ? 0 : object?.object(forKey: "IsSuccessed") as! Int
            if state > 0 {
                let result = JSON(data: (responseObject as! NSData) as Data)
              //  print(result);
                
                var updateArray = [RNUserRecordModel]()
                var repairArray = [RNUserRecordModel]()
                
                
                let updateJson = result["UpdateJson"].stringValue
                let updateContent = JSON.init(parseJSON: updateJson).array
                
                if let u = updateContent {
                    for (index, value) in u.enumerated(){
                        let model = RNUserRecordModel()
                        model.id = value["Id"].intValue
                        model.deviceId = value["DeviceID"].stringValue
                        model.name = value["FilterID"].stringValue
                       // model.year = value["FilterUpdateTime"].stringValue
                        model.isRealData = true
                        model.index = index + 1
                        
                        let time = value["FilterUpdateTime"].stringValue
                        if (time.hasPrefix("\\Date(") || time.hasPrefix("/Date(")) && (time as NSString).length >= 9{
                            let  timeStamp  =  DateTool.dateFromServiceTimeStamp(time)!
                            
                            model.year =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy-MM-dd")
                        }else{
                             model.year = time
                        }
                        
                        updateArray.append(model)
                    }

                }
                
                let repairJson = result["RepairJson"].stringValue
                let repairContent = JSON.init(parseJSON: repairJson).array
                if let r = repairContent {
                    for (index, value) in r.enumerated(){
                        let model = RNUserRecordModel()
                        model.id = value["Id"].intValue
                        model.deviceId = value["DeviceID"].stringValue
                        model.name = value["RepairContent"].stringValue
                       // model.year = value["RepairTime"].stringValue
                        model.isRealData = true
                        model.index = index + 1
                        
                        let time = value["RepairTime"].stringValue
                        if (time.hasPrefix("\\Date(") || time.hasPrefix("/Date(")) && (time as NSString).length >= 9{
                            let  timeStamp  =  DateTool.dateFromServiceTimeStamp(time)!
                            
                            model.year =  DateTool.stringFromDate(timeStamp, dateFormat: "yyyy-MM-dd")
                        }else{
                            model.year = time
                        }
                        
                        repairArray.append(model)
                    }
                    
                }
                
                self.dataSourceDic[2] = updateArray
                self.dataSourceDic[3] = repairArray
                
               self.tableView.reloadData()
                
            }
            else{
              
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: object?.object(forKey: "ResultMessage") as! String)
            }

            
            }) {(operation, error) in
                
                 MBProgressHUD.hide(for: UIApplication.shared.keyWindow, animated: true)
                
                if appDelegate.reachOfNetwork?.currentReachabilityStatus().rawValue==0
                {//网络未连接错误
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("提示", subTitle: "网络未连接")
                    
                }else{//网络连接，其它原因
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("提示", subTitle: error.localizedDescription)
                }

        }
        
        
    }
    
    func mergeParams() -> Bool{
        
        
//        // 连接蓝牙成功之后
//        let vol = scanResultCell!.totalVolumeTextField.text
//        guard vol != nil && vol! != "" else{
//            let alertView=SCLAlertView()
//            alertView.addButton("确定", action: {})
//            alertView.showNotice("提示", subTitle: "请先设定总净水量")
//            
//            return
//            
//        }
//        
//        let dateString = scanResultCell!.updateFilterTimeTextField.text
//        guard dateString != nil && dateString! != "" else{
//            let alertView=SCLAlertView()
//            alertView.addButton("确定", action: {})
//            alertView.showNotice("提示", subTitle: "请先选择滤芯更换日期")
//            
//            return
//        }
        
        guard let phone = scanResultCell?.phoneTextField.text else{
            return false
        }
        
        guard phone.isAllNumber && (phone as NSString).length == 11 else{
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("提示", subTitle: "联系人电话格式不正确")

            return false
        }

        
        guard let currentuser = User.currentUser else{
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("提示", subTitle: "抱歉,未获取到当前用户信息")
            return false
        }
        
        guard let _ = currentuser.name else{
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("提示", subTitle: "抱歉,未获取到当前用户信息")
            return false
        }
        
        let dic = NSMutableDictionary() // 初始化提交参数字典
        
        dic.setValue(userJsonInitWithDic() , forKey: "userJson")
        dic.setValue(deviceJsonInitWithDic() , forKey: "deviceJson")
        
        
        // 过滤空数据
        var ftArr = [filterModel]()
        for item in filterSettingArray {
            if item.filterName == "" && item.filterYear == "0" {
                // 不添加
            } else{
                ftArr.append(item)
            }
        }
        dic.setValue(setJsonInitWithDic(ftArr) , forKey: "setJson")
        
        // 过滤空数据
        var uArr = [RNUserRecordModel]()
        if let arrSecond =  dataSourceDic[2]{
            
            for item in arrSecond {
                if !(item.name == "" && item.year == "") {
                    uArr.append(item)
                }
            }
        }
        dic.setValue(updateJsonInitWithDic(uArr) , forKey: "updateJson")
        
        // 过滤空数据
        var rArr = [RNUserRecordModel]()
        if let arrThird = dataSourceDic[3]{
            for item in arrThird {
                if !(item.name == "" && item.year == "") {
                    rArr.append(item)
                }
            }
        }
        dic.setValue(repairJsonInitWithDic(rArr) , forKey: "repairJson")
        
        finalString = dicToJsonString(dic)!
        finalString = finalString.replacingOccurrences(of: "\\", with: "")

        print("-----------\(finalString)")
        finalParamsDic = NSMutableDictionary()
        finalParamsDic?.setValue(finalString, forKey: "data")
        
        return true
    }
    
    func userJsonInitWithDic() -> NSMutableDictionary{
        
       
        let dic = NSMutableDictionary()
        dic.setValue(scanResultCell?.linkerTextField.text ?? "", forKey: "userName")
        dic.setValue(scanResultCell?.phoneTextField.text ?? "", forKey: "mobile")
        dic.setValue(scanResultCell?.provinceTextField.text ?? "", forKey: "province")
        dic.setValue(scanResultCell?.cityTextField.text ?? "", forKey: "city")
        
        if scanResultCell?.specificAddressTextView.text == "请填入完整的地址" {
            dic.setValue("", forKey: "area")
            dic.setValue("", forKey: "adress")
        }else{
            dic.setValue(scanResultCell?.specificAddressTextView.text ?? "", forKey: "area")
            dic.setValue(scanResultCell?.specificAddressTextView.text ?? "", forKey: "adress")
        }
        
        dic.setValue(User.currentUser!.name! , forKey: "currentUser")
        return dic
    }
    
    func deviceJsonInitWithDic() -> NSMutableDictionary{
      //  let array = NSMutableArray()
        
        let dic = NSMutableDictionary()
         dic.setValue(number, forKey: "deviceID") // deviceID
         dic.setValue(scanResultCell?.machineBrandTextField.text ?? "", forKey: "deviceBrand")
         dic.setValue(scanResultCell?.machineSizeTextField.text ?? "", forKey: "deviceModle")
         dic.setValue(typeCode, forKey: "deviceType") // 类型
        
        if let vol = scanResultCell?.totalVolumeTextField.text {
            dic.setValue(Int(vol), forKey: "waterTotal")
        }else{
            dic.setValue(100, forKey: "waterTotal")
        }
        
         dic.setValue(scanResultCell?.updateFilterTimeTextField.text ?? "", forKey: "modifyFilterTime")
        
//        if let d = dicToJsonString(dic){
//            array.addObject(d)
//        }
        
       //  array.addObject(dic)
        
        return dic
    }
    
    func setJsonInitWithDic(_ arr: [filterModel]) -> NSArray{
        let array = NSMutableArray()
        for item in arr{
            let dic = NSMutableDictionary()
            dic.setValue(number, forKey: "deviceID") // 没有,默认为空
            dic.setValue(item.index, forKey: "filterID") // 滤芯级数
            dic.setValue(item.filterName, forKey: "filterName")// 滤芯名称
            
            if let y = Int(item.filterYear){
                dic.setValue(y, forKey: "filterLife")// 滤芯寿命
            }
            
            dic.setValue(User.currentUser!.name! , forKey: "currentUser")
            
//            if let d = dicToJsonString(dic){
//                array.addObject(d)
//            }
             array.add(dic)
        }
        
        return array
    }
    
    func updateJsonInitWithDic(_ arr:[RNUserRecordModel]) -> NSArray{
        let array = NSMutableArray()
        for item in arr{
            let dic = NSMutableDictionary()
            dic.setValue(number, forKey: "deviceID") // 没有,默认为空
            
            if let jishu = item.name {
                
                if let j = Int(jishu) {
                  dic.setValue(j, forKey: "filterID") // 滤芯级数
                }
                
            }
           
            dic.setValue(item.year ?? "", forKey: "filterUpdateTime")// 滤芯更换日期
            dic.setValue(item.id, forKey: "id");
            dic.setValue(User.currentUser!.name! , forKey: "currentUser")

            
//            if let d = dicToJsonString(dic){
//                array.addObject(d)
//            }
             array.add(dic)
        }
        
        return array
    }
    
    
    func repairJsonInitWithDic(_ arr:[RNUserRecordModel]) -> NSArray{
        let array = NSMutableArray()
        for item in arr{
            let dic = NSMutableDictionary()
            dic.setValue(number, forKey: "deviceID") 
            dic.setValue(item.name ?? "", forKey: "repairContent") // 维修内容
            dic.setValue(item.year ?? "", forKey: "repairTime")// 维修时间
            dic.setValue(item.id, forKey: "id");
            dic.setValue(User.currentUser!.name! , forKey: "currentUser")
            
//            if let d = dicToJsonString(dic){
//                array.addObject(d)
//            }
             array.add(dic)
        }
        
        return array
    }
    
    func uploadSubmitData(){
       
        
        if !mergeParams(){
            return
        }
        
        guard let _ = finalParamsDic else{
            return
        }
        
        MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow, animated: true)
        print("-----\(finalParamsDic)")
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        // manager
        //test.oznerwater.com
//        http://hoyo.ozner.net/OznerFamilyService/Handlers/DeviceAppServiceAddHandlers.ashx
        manager.post("http://hoyo.ozner.net/OznerFamilyService/Handlers/DeviceAppServiceAddHandlers.ashx", parameters: finalParamsDic!, success: { (operation, responseObject) in
            
            
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow, animated: true)
            
            let error: NSError? = nil
            let object: AnyObject?
            do{
                object = try! JSONSerialization.jsonObject(with: responseObject as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            }
            if error != nil || object == nil || !(object is NSDictionary) {
                return
            }
            // print(object)
            let state = object?.object(forKey: "IsSuccessed") == nil ? 0 : object?.object(forKey: "IsSuccessed") as! Int
            if  state > 0 {
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: { [weak self] in
                
                    
                    if (self?.isLinkedBluetooth)!{
                        // 断开蓝牙连接
                        OznerBlueManager.instance().disConnectCurrentLink()
                        
                        self?.isLinkedBluetooth = false
                    }
                   
                    
                    for vc in ( self?.navigationController?.viewControllers)! {
                        
                        if vc.isKind(of: HomeTableViewController.self){
                            
                           // NSNotificationCenter.defaultCenter().postNotificationName("UPDATEWAITORDER", object: nil) // 发送通知到ListsDetailViewController让其更新数据
                           _ = self?.navigationController?.popToViewController(vc, animated: true)
                        }
                    }

                    
                })
                alertView.showSuccess("提示", subTitle: "提交信息成功")
            }
            else{
                
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: object?.object(forKey: "ResultMessage") as! String)
            }
            

            }) { (operation, error) in
                
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow, animated: true)
                
                if appDelegate.reachOfNetwork?.currentReachabilityStatus().rawValue==0
                {//网络未连接错误
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("提示", subTitle: "网络未连接")
                    
                }else{//网络连接，其它原因
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("提示", subTitle: error.localizedDescription)
                }
        }
    }
    
    // MARK: - jsonstring转换
    // 字典转 jsonString
    func dicToJsonString(_ dic: NSDictionary) -> String?{
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        guard let haveData = data else{
            return nil
        }
        var strJson = String(data: haveData, encoding: String.Encoding.utf8)
        
        strJson = strJson?.replacingOccurrences(of: "\n", with: "")
        //strJson = strJson?.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        return strJson
    }
    
    func arrayToJsonString(_ arr: NSArray) -> String?{
        
        let data = try? JSONSerialization.data(withJSONObject: arr, options: JSONSerialization.WritingOptions.prettyPrinted)
        
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
extension RNScanResultViewController{
    
    func dissBtnAction() {
        _ = navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate && UITableViewDatasource

extension RNScanResultViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //
    ////        switch indexPath.section {
    ////        case 0:
    ////            return 300
    ////        case 1:
    ////            return 30
    ////        case 2:
    ////            return 60
    ////
    ////        case 3:
    ////            return 40
    ////        case 4:
    ////            return 90
    ////        default:
    ////            return 0
    ////        }
    //
    //        if indexPath.section == 0 {
    //            return 607
    //        }else {
    //            return 40
    //        }
    //
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return filterSettingCount
        case 2:
            
            if let c = dataSourceDic[section]?.count {
                return c + 1
            }else{
                return 0
            }
            
           // return (dataSourceDic[section]?.count)! + 1
            
        case 3:
            if let c = dataSourceDic[section]?.count {
                return c + 1
            }else{
                return 0
            }
           // return (dataSourceDic[section]?.count)! + 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //
    //        if indexPath.section == 0 {
    //            return UITableViewAutomaticDimension
    //        }else if indexPath.section == 1{
    //            return 40
    //        }else if indexPath.section == 2{
    //            if indexPath.row == 0 {
    //                return 65
    //            }else{
    //                return 40
    //            }
    //        }else if indexPath.section == 3{
    //            if indexPath.row == 0 {
    //                return 41
    //            }else{
    //                return 40
    //            }
    //        }else{
    //            return 90
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            
                if indexPath.row == 0 {
                    return 30
                }else{
                    return 36
                }
            
        case 2:
            
                if indexPath.row == 0 {
                    return 65
                }else{
                    return 36
                }
            
            
        case 3:
            
                if indexPath.row == 0 {
                    return 51
                }else{
                    return 36
                }
            
        case 4:
            return 90
        default:
             return UITableViewAutomaticDimension
        }
        
        // return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2 {
            return 0.01
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        
        if indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell") as! RNScanResultTableViewCell
            
            let tempCell = cell as! RNScanResultTableViewCell
            tempCell.typeLabel.text = typeCode
            tempCell.numberLabel.text = number
            
            scanResultCell = tempCell
        }
        else if indexPath.section == 1 {
            
            if indexPath.row == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell02") as! RNScanResultTableViewCell02
                let tempCell = cell as! RNScanResultTableViewCell02
                
                tempCell.delegate = self
                
                
                tempCell.recordCount = filterSettingCount - 1
                
                tempCell.indexPath = indexPath
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell02_02") as! (RNScanResultTableViewCell02_02)
                let tempCell = cell as! RNScanResultTableViewCell02_02
                tempCell.delegate = self
                
                // let array = dataSourceDic[indexPath.section]!
                //                if indexPath.row < array.count{
                
                let model = filterSettingArray[indexPath.row-1]
                tempCell.configCell(indexPath, myModel:model)
                
                scanResultCell02_02 = tempCell
                // }
                
                
            }
        }
        else if indexPath.section == 2 {
            
            if indexPath.row == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell03") as! RNScanResultTableViewCell03
                let tempCell = cell as! RNScanResultTableViewCell03
                
                tempCell.delegate = self
                
                tempCell.indexPath = indexPath
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell03_02") as! (RNScanResultTableViewCell03_02)
                let tempCell = cell as! RNScanResultTableViewCell03_02
                
                tempCell.delegate = self
                
                let array = dataSourceDic[indexPath.section]!
                
                let model = array[indexPath.row - 1]
                tempCell.configCell(indexPath, model: model)
                
            }
        }
        else if indexPath.section == 3 {
            
            if indexPath.row == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell04") as! RNScanResultTableViewCell04
                let tempCell = cell as! RNScanResultTableViewCell04
                
                tempCell.delegate = self
                
                tempCell.indexPath = indexPath
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell04_02") as! (RNScanResultTableViewCell04_02)
                let tempCell = cell as! RNScanResultTableViewCell04_02
                
                tempCell.delegate = self
                
                let array = dataSourceDic[indexPath.section]!
                
                let model = array[indexPath.row - 1]
                tempCell.configCell(indexPath, model: model)
                
            }
        }
        else if indexPath.section == 4 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "RNScanResultTableViewCell05") as! RNScanResultTableViewCell05
            let tempCell = cell as! RNScanResultTableViewCell05
            
            tempCell.delegate = self
        }
        
        
        cell?.selectionStyle = .none
        //
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowheight = heightForIndex[indexPath]
        if (rowheight != nil) {
            return rowheight!
        }else{
            return 600
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isChangeForCellHeight{
            
            let rowHeight = cell.frame.size.height
            heightForIndex[indexPath] = rowHeight
        }else{
            if let _ = heightForIndex[indexPath]{
                // 不缓存
            }else{
                let rowHeight = cell.frame.size.height
                heightForIndex[indexPath] = rowHeight
            }
        }

    }
}


// MARK: - RNScanResultTableViewCellDelegate

//extension RNScanResultViewController: RNScanResultTableViewCellDelegate{
//
//
//}

// MARK: - RNScanResultTableViewCell02Delegate

extension RNScanResultViewController: RNScanResultTableViewCell02Delegate{
    
    func addFilterSettingRecord(_ count: Int, index: IndexPath){
        
        if count < 6 {
            //            var array = dataSourceDic[index.section]
            
            let model = filterModel()
            model.index = index.row
            model.filterName = ""
            model.filterYear = "0"
            filterSettingArray.append(model)
            
            let path = IndexPath(row: index.row + filterSettingCount , section: index.section) // 将要插入的 cell 的索引
            
            //            let model = RNUserRecordModel()
            //            model.isRealData = false
            //            model.name = ""
            //            model.year = ""
            //            array?.append(model)
            //            dataSourceDic.updateValue(array!, forKey: index.section)
            filterSettingCount = filterSettingCount + 1
            
            //  let indexSet = NSIndexSet(index: index.section)
            
            tableView.insertRows(at: [path], with: UITableViewRowAnimation.right)
//            
////            tableView.beginUpdates()
////            tableView.endUpdates()
//            tableView.scrollToRow(at: path, at: .none, animated: true)
//            tableView.beginUpdates()
//            tableView.insertRows(at: [path], with: UITableViewRowAnimation.right)
//            tableView.endUpdates()
//            tableView.scrollToRow(at: path, at: .middle, animated: true)
            
            // TO FIX: iOS10.2版本之后,插入一行 tableView就莫名其妙自动上滚至顶,10.2之前正常
            
        }else{
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "滤芯设定最多五级")
        }
        
    }
    
}

// MARK: - RNScanResultTableViewCell02_02Delegate

extension RNScanResultViewController: RNScanResultTableViewCell02_02Delegate{
    
    func selectionFilterSetting(_ index: IndexPath){
        
        
    }
    
    func delectRow(_ index: IndexPath){
        
        guard filterSettingCount > 0 else{
            return
        }
        
        let alertView=SCLAlertView()
        alertView.addButton("确定", action: {
            
            self.filterSettingArray.remove(at: index.row-1)
           // self.initFilterSettingArray()
            
            self.filterSettingCount = self.filterSettingCount - 1
            
            let indexSet = IndexSet(integer: index.section)
            
            // self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.reloadSections(indexSet, with: UITableViewRowAnimation.fade)
            
            
            
            // self.tableView.reloadData()
        })
        alertView.addButton("取消", action:{})
        alertView.showNotice("提示", subTitle: "是否删除添加滤芯设定?")
        
    }
    
    func updateFilterSettingModel(_ model: filterModel){
        
        for (index, _) in filterSettingArray.enumerated() {
            if model.index == index+1 {
                filterSettingArray[index] = model
            }
        }
    }
    
}

// MARK: - RNScanResultTableViewCell03Delegate

extension RNScanResultViewController: RNScanResultTableViewCell03Delegate{
    
    func addChangeFilterRecord(_ index: IndexPath){
        
        var array = dataSourceDic[index.section]
        
        let path = IndexPath(row: index.row + array!.count + 1, section: index.section) // 将要插入的 cell 的索引
        
        let model = RNUserRecordModel()
        model.isRealData = false
        model.name = ""
        model.year = ""
        model.id = -1
        model.index = index.row
        array?.append(model)
        dataSourceDic.updateValue(array!, forKey: index.section)
        
        tableView.insertRows(at: [path], with: UITableViewRowAnimation.right)
//        //self.tableView.reloadData()
//        
////        tableView.beginUpdates()
////        tableView.endUpdates()
//        tableView.scrollToRow(at: path, at: .none, animated: true)
        
//        tableView.beginUpdates()
//        tableView.insertRows(at: [path], with: UITableViewRowAnimation.right)
//        tableView.endUpdates()
//        tableView.scrollToRow(at: path, at: .middle, animated: true)
        
         // TO FIX: iOS10.2版本之后,插入一行 tableView就莫名其妙自动上滚至顶,10.2之前正常
    }
    
}

// MARK: - RNScanResultTableViewCell03-02Delegate

extension RNScanResultViewController: RNScanResultTableViewCell03_02Delegate{
    
    func selectionFilterChangeRecode(_ tag: Int, index: IndexPath){
        
        
    }
    
    func delectRowFilterChangeRecode(_ index: IndexPath){
        
        let alertView=SCLAlertView()
        alertView.addButton("确定", action: {
            
            var array = self.dataSourceDic[index.section]
            array?.remove(at: index.row-1)
            self.dataSourceDic.updateValue(array!, forKey: index.section)
            let indexSet = IndexSet(integer: index.section)
            
            //  self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.reloadSections(indexSet, with: UITableViewRowAnimation.fade)
            
            // self.tableView.reloadData()
        })
        alertView.addButton("取消", action:{})
        alertView.showNotice("提示", subTitle: "是否删除添加记录")
        
    }
    
    func updateFilterChangeRecode(_ model: RNUserRecordModel) {
        
        for (index, value) in dataSourceDic[2]!.enumerated() {
            if model.index == value.index {
                dataSourceDic[2]![index] = model
            }
        }
        
    }
    
}

// MARK: - RNScanResultTableViewCell04Delegate

extension RNScanResultViewController: RNScanResultTableViewCell04Delegate{
    
    func addServiceRecord(_ index: IndexPath){
        
        var array = dataSourceDic[index.section]
        
        let path = IndexPath(row: index.row + array!.count + 1, section: index.section) // 将要插入的 cell 的索引
        
        let model = RNUserRecordModel()
        model.isRealData = false
        model.name = ""
        model.year = ""
        model.id = -1
        model.index = index.row
        array?.append(model)
        
        //        for item in array! {
        //            print("*************\(item.isRealData)")
        //        }
        dataSourceDic.updateValue(array!, forKey: index.section)
        
        //let indexSet = NSIndexSet(index: index.section)
        
       tableView.insertRows(at: [path], with: UITableViewRowAnimation.right)
//        
////        tableView.beginUpdates()
////        tableView.endUpdates()
//        tableView.scrollToRow(at: path, at: .none, animated: true)
        
//        tableView.beginUpdates()
//        tableView.insertRows(at: [path], with: UITableViewRowAnimation.right)
//        tableView.endUpdates()
//        tableView.scrollToRow(at: path, at: .middle, animated: true)
        
        // print("______________________________")
        
         // TO FIX: iOS10.2版本之后,插入一行 tableView就莫名其妙自动上滚至顶,10.2之前正常
    }
}

// MARK: - RNScanResultTableViewCell04-02Delegate
extension RNScanResultViewController:  RNScanResultTableViewCell04_02Delegate{
    
    func selectionServiceRecord(_ index: IndexPath){
        
        
    }
    
    func delectRowServiceRecord(_ index: IndexPath){
        
        let alertView=SCLAlertView()
        alertView.addButton("确定", action: {
            
            var array = self.dataSourceDic[index.section]
            array?.remove(at: index.row-1)
            self.dataSourceDic.updateValue(array!, forKey: index.section)
            let indexSet = IndexSet(integer: index.section)
            
            //  self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.reloadSections(indexSet, with: UITableViewRowAnimation.fade)
            
            // self.tableView.reloadData()
        })
        alertView.addButton("取消", action:{})
        alertView.showNotice("提示", subTitle: "是否删除添加记录")
        
    }
    
    func updateServiceRecord(_ model: RNUserRecordModel) {
        
        for (index, value) in dataSourceDic[3]!.enumerated() {
            if model.index == value.index {
                dataSourceDic[3]![index] = model
            }
        }
        
    }
    
}

// MARK: - RNScanResultTableViewCell05Delegate

extension RNScanResultViewController: RNScanResultTableViewCell05Delegate{
    
    func confirmAndSave() {
        
      //  self.uploadSubmitData()

        self.view.endEditing(true)
        
        if scanResultCell?.phoneTextField.text == "" || scanResultCell?.phoneTextField.text?.characters.count != 11{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "联系电话为空或者格式不正确")
            return
        }
//        print("**********************")
//        for item in dataSourceDic[2]! {
//            print(item.name ?? "")
//            print(item.year ?? "")
//        }
//        print("----------------------")
//        for item in dataSourceDic[3]! {
//            print(item.name ?? "")
//            print(item.year ?? "")
//        }
//        print("++++++++++++++++++++++++")
        // 获得上次更换滤芯日期 和 总水量
        if !getTimeAndMaxvol() {
            return
        }
        
        // 拼接要写入设备数组
        var bluetoothArray = [[String: String]]()
        for item in filterSettingArray {
            print("------\(item.filterName)")
            print("++++++\(item.filterYear)")
            if item.filterName == "" && item.filterYear == "0" {
                continue
            }else if item.filterYear == "0"{
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "滤芯设定不能为0或空")
                return

            }else{
                
                guard let t = timeAndMaxvol.0 else{
                    return
                }
                guard let v = timeAndMaxvol.1 else{
                    return
                }
                
                let maxtime = Int(item.filterYear)! * 30 * 24 * 60 // 转成分钟
                let dic = ["index": "\(item.index-1)", "time": "\(t)", "maxTime": "\(maxtime)", "maxVol": "\(v)"]
                
                bluetoothArray.append(dic)
            }
            
        }
        
        
        // 滤芯设定写入设备
        
        if bluetoothArray.count > 0{
            
           // if !isLinkedBluetooth {
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                //   MBProgressHUD.showAdded(to: self.view, animated: true)
               // hud?.mode = MBProgressHUDMode.text
                hud?.labelText = "蓝牙连接中..."
                hud?.detailsLabelText = "正在连接蓝牙设备并写入数据,请确认设备蓝牙和手机蓝牙都已打开"
                hud?.show(true)
                var str = ""
                OznerBlueManager.instance().commitData(bluetoothArray, callBack: { (error) in
                    str = str + "\n"+"code:\((error as! NSError).code)===="+"描述:\((error as! NSError).domain)"
                    
                    //                print("**********************")
                    //                print(str)
                    //                print("**********************")
                    
                    
                    
                    if (error as! NSError).code < 0 {
                        
                        //  MBProgressHUD.hide(for: self.view, animated: true)
                        
                        hud?.hide(true)
                        
                        let alertView=SCLAlertView()
                        alertView.addButton("确定", action: {})
                        alertView.showNotice("提示", subTitle: "\((error as! NSError).domain)")
                        
                        return
                    }else if (error as! NSError).code == 5 {
                        
                        // MBProgressHUD.hide(for: self.view, animated: true)
                        self.isLinkedBluetooth = true
                        hud?.hide(true)
                        
                        let alertView=SCLAlertView()
                        alertView.addButton("确定", action: {
                            
                            // 执行提交后台操作
                            self.uploadSubmitData()
                        })
                        alertView.showInfo("提示", subTitle: "\((error as! NSError).domain),是否开始向服务器提交数据")
                    }
                })

//            }else{
//                // 执行提交后台操作
//                self.uploadSubmitData()
//            }
            
        }else{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {
                
               // self.isLinkedBluetooth = true
                // 执行提交后台操作
                self.uploadSubmitData()
            })
            alertView.addButton("取消", action: {})
            alertView.showInfo("提示", subTitle: "没有对滤芯进行任何设定,是否继续向服务器提交数据")
        }
        
    }
    
    // 获取 time 和 maxVol
    func getTimeAndMaxvol() -> Bool{
        
        var mytime: CLong?
        var maxvol: String?
        
        let vol = scanResultCell!.totalVolumeTextField.text
        
        guard vol != nil && vol! != "" else{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "请先设定总净水量")
            
            return false
            
        }
        maxvol = vol
        
        
        let dateString = scanResultCell!.updateFilterTimeTextField.text
        
        guard dateString != nil && dateString! != "" else{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "请先选择滤芯更换日期")
            
            return false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: dateString!)
        
        mytime = CLong(date!.timeIntervalSince1970)

        
        
        timeAndMaxvol = (mytime, maxvol)
        
        return true
        
    }
}

