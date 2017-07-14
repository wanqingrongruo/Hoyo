//
//  SubmitController.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 15/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
//import IQKeyboardManagerSwift
import IQKeyboardManager
import ALCameraViewController
import SwiftyJSON
import MBProgressHUD


class SubmitController: UIViewController {
    
    // MARK: - properties - 即定义的各种属性
    
    var tableView: UITableView!
    
    var orderDetail:OrderDetail? // 订单详情--从上个界面带来
    var payInfos = [RNPAYDetailModel]()// 支付信息 -- 从上个界面带来
    
    // 各种 cell
    var tmpCell01: RNSubmitCell01?
    var tmpCell02: RNSubmitCell02?
    var tmpCell03: RNSubmitCell03?
    var tmpCell04: RNSubmitCell04?
    var feeShowCell: RNFeeShowCell?
    var otherFeeCell: RNOtherFeeTableViewCell?
    var payWayCell: RNPaywayTableViewCell?
    var signerCell: RNSignerTableViewCell?
    
    // 选择用时需要的属性
    var useTimeData = [[String]]() // 选择用时展示的数据
    var useTimeShow = "选择用时" // 用时显示
    var useTimeAdd = 0 // 用时提交字段,Int
    
    // 扫描二维码需要属性
    var scanWhichTextFied: String? // 输入框的 tag
    var idScanResult = "data is empty" // 机器 ID扫描结果
    var imeiScanResult = "data is empty" // IMEI扫描结果
    var throghtTrainScanResult = "data is empty" //直通车扫描结果
    
    // 选择配件清单需要属性
    var isSignArr = [Bool]()
    var productinfos = [Int:ProductInfo]() // 配件信息
    var productInfoArr = [ProductInfo]() // 使用配件清单数组
    
    // 需要支付的总费用 - 合计
    var money: Double = 0.0
    var uploadMoney: Double = 0.0 // 提交给后台的数据 money对应的值就是输入框里面的值+配件费用,,获取的 payinfos 里的各项费用不用加
    
    // 故障数据
    lazy var troubleModelArr : [TroubleDetail] = { // 故障信息数组 -- 从 json 数据中读取
        
        let path =  Bundle.main.path(forResource: "trouble", ofType: "json")
        
        let data =  try? Data(contentsOf: URL(fileURLWithPath: path!))
        var  tmptroubleDetailArr = [TroubleDetail]()
        let json =  JSON(data: data!)
        for item in json.array! {
            let tmptroubleDetail = TroubleDetail()
            tmptroubleDetail.margin = item["margin"].stringValue
            var    tmpsubresArr =  [String]()
            for item1 in item["subres"].array!
            {
                tmpsubresArr.append(item1.stringValue)
                
            }
            tmptroubleDetail.subres = tmpsubresArr
            
            tmptroubleDetailArr.append(tmptroubleDetail)
            
        }
        return tmptroubleDetailArr
    }()
    var faultReasons = [String]() // 故障原因
    var dealMethods = [[String]]() // 解决办法
    
    //
    var currentTag:Int = 0 // 标记当前的提交的 cell
    
    var finalParamsDic: NSMutableDictionary? //最终提交的参数字典
    var imageDic: NSMutableDictionary? // 图片字典
    var palatteDic: NSMutableDictionary? // 签名字典
    
    // 其他费用类型数组 -- 另一个控制器回调回来
    fileprivate lazy var otherFeeTitleArray = {
        
        return [String]()
    }()
    
    // 其他费用金额数组
    fileprivate lazy var otherFeeArray = {
        
        return [Double]()
    }()
    var otherFee = 0.0
    
    var tmpIndex = 199
    
    var myPaletteInfo: (Bool, UIImage?) = (false, nil) //签名回调
    
    var manager: CLLocationManager?
    var isLocationSuccess: Bool = false // 是否定位成功
    // 经纬度
    var myLongtitude: String? = nil
    var myLatitude: String? = nil
    
    
    // 根据是否是维护维修/换机单 -> 是否有 料号 决定是否显示查询水值
    var sectionCount = 1 // default, 需要充值: 2   // 第一组
    
    var isLinkedBluetooth =  true // 是否已经连接蓝牙. 默认 true, 当满足需要连接时变为 false
    
    // MARK: - init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(orderDetail:OrderDetail, payInfos: [RNPAYDetailModel]) {
        
        var nibNameOrNil = String?("SubmitController.swift")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        self.orderDetail=orderDetail
        self.payInfos = payInfos
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    // MARK: -  Life cycle - 即生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title  = "确认完成"
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        let types = ["维修维护", "换货"]
        if let type = orderDetail?.troubleHandleType, types.contains(type), let deviceType = orderDetail?.deviceType, deviceType == "1.3.030432" { // 只有料号是 1.3.030432 维修和换货单才需要修复水值
        
            sectionCount += 1
            
            isLinkedBluetooth = false
        }
        
        
        
        initUseTimeData()
        
        myLocationManager()
        
        setupTableView()
        
        // 获取故障原因
        for item in troubleModelArr {
            faultReasons.append(item.margin! as String)
        }
        
        // 获取解决办法
        for item in troubleModelArr {
            dealMethods.append(item.subres!)
        }
        
        finalParamsDic = NSMutableDictionary() // 初始化提交参数字典
        statisticsTotalFee() // 计算服务费
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    deinit{
        
        
    }
    
}

// MARK: - Public Methods - 即系统提供的方法

extension SubmitController{
    
    // 跳转控
    func skipToRobOneVC(){
        
        guard let step = self.navigationController?.viewControllers.count else {
            
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
            return
        }
        
        guard step >= 3 else {
            
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
            return
        }
        
        guard let vc = navigationController?.viewControllers[step-3] else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 发送通知到ListsDetailViewController让其更新数据
        _ = self.navigationController?.popToViewController(vc, animated: true)
        
        //        if let vcs = navigationController?.viewControllers {
        //
        //            for vc in vcs {
        //
        //                if vc.isKind(of: RobListOneController.self){
        //
        //                    NotificationCenter.default.post(name: Notification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 发送通知到RobListOneController让其更新数据
        //                    _ = navigationController?.popToViewController(vc, animated: true)
        //                }
        //            }
        //
        //        }else{
        //
        //            let alert = SCLAlertView()
        //            alert.addButton("确定", action: {})
        //            alert.showError("提示", subTitle: "跳转失败,请手动返回")
        //        }
        
    }
    
}

// MARK: - Private Methods - 即私人写的方法

extension  SubmitController{
    
    // 常见tableView
    func setupTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: HEIGHT_SCREEN-64), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        tableView.register(UINib(nibName: "RNSubmitCell01", bundle: Bundle.main), forCellReuseIdentifier: "RNSubmitCell01")
        tableView.register(UINib(nibName: "RNSubmitCell02", bundle: Bundle.main), forCellReuseIdentifier: "RNSubmitCell02")
        tableView.register(UINib(nibName: "RNSubmitCell03", bundle: Bundle.main), forCellReuseIdentifier: "RNSubmitCell03")
        tableView.register(UINib(nibName: "RNSubmitCell04", bundle: Bundle.main), forCellReuseIdentifier: "RNSubmitCell04")
        
        tableView.register(UINib(nibName: "SubmitListsCell", bundle: Bundle.main), forCellReuseIdentifier: "SubmitListsCell")
        tableView.register(UINib(nibName: "RNFeeShowCell", bundle: Bundle.main), forCellReuseIdentifier: "RNFeeShowCell")
        tableView.register(UINib(nibName: "RNOtherFeeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RNOtherFeeTableViewCell")
        tableView.register(UINib(nibName: "RNPaywayTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RNPaywayTableViewCell")
        tableView.register(UINib(nibName: "RNSignerTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RNSignerTableViewCell")
        tableView.register(UINib(nibName: "SubmitBtn", bundle: Bundle.main), forCellReuseIdentifier: "SubmitBtn")
        
        
        tableView.estimatedRowHeight = 1500
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        
        view.addSubview(tableView)
    }
    
    // 初始化选择用时所需要的数据
    func initUseTimeData(){
        var hourArray = [String]()
        for hour in 0...24 {
            let str = "\(hour)小时"
            hourArray.append( str)
        }
        
        var minuteArray = [String]()
        for minute in 0...59 {
            let str = "\(minute)分钟"
            minuteArray.append( str)
        }
        
        useTimeData.append(hourArray)
        useTimeData.append(minuteArray)
    }
    
    // 统计提交所需要的参数
    func mergePublicParams() -> Bool{
        
        guard orderDetail?.id != nil else{
            return false
        }
        guard finalParamsDic != nil else{
            return false
        }
        finalParamsDic!["orderid"] = orderDetail?.id
        // finalParamsDic!["money"] = "\(money)"
        
        
        switch currentTag { // 根据不同的 cell 获取内容
        case 1:
            return mergerCell01()
        case 2:
            return mergerCell02()
        case 3:
            return mergerCell03()
        case 4:
            return mergerCell04()
        default:
            break
        }
        
        return true
        
    }
    
    func mergerCell01() -> Bool{
        
        guard !(tmpCell01!.selectDayButton.currentTitle! as NSString).isEqual(to: "选择日期") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达日期")
            
            return false
        }
        
        guard !(tmpCell01!.selectTimeButton.currentTitle! as NSString).isEqual(to: "选择时间") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达确切时间")
            
            return false
        }
        
        finalParamsDic!["arrivetime"] = tmpCell01!.selectDayButton.currentTitle! + tmpCell01!.selectTimeButton.currentTitle! // 到达时间
        
        guard !(tmpCell01!.selectWorkTimeButton.currentTitle! as NSString).isEqual(to: "选择用时") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择工作用时")
            
            return false
        }
        
        finalParamsDic!["usetime"] = useTimeAdd //用时
        finalParamsDic!["machinetype"] = tmpCell01!.machineIdTextField.text ?? "未填" // 机器 id
        finalParamsDic!["machinecode"] = tmpCell01!.IMEITextField.text ?? "未填" // IMEI
        
        finalParamsDic!["payWay"] = payWayCell!.payWay
        finalParamsDic!["ServiceCode"] = tmpCell01!.throughTrainTextField.text ?? "未填"
        finalParamsDic!["machineVersion"] = tmpCell01!.machineIdTextField.text ?? "未填"
        
        finalParamsDic!.setValue(initWithDict(productInfoArr), forKey: "products") // 配件信息
        
        return true
    }
    
    func mergerCell02() -> Bool{
        
        guard !(tmpCell02!.selectDayButton.currentTitle! as NSString).isEqual(to: "选择日期") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达日期")
            
            return false
        }
        
        guard !(tmpCell02!.selectTimeButton.currentTitle! as NSString).isEqual(to: "选择时间") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达确切时间")
            
            return false
        }
        
        finalParamsDic!["arrivetime"] = tmpCell02!.selectDayButton.currentTitle! + tmpCell02!.selectTimeButton.currentTitle! // 到达时间
        
        guard !(tmpCell02!.selectWorkTimeButton.currentTitle! as NSString).isEqual(to: "选择用时") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择工作用时")
            
            return false
        }
        
        finalParamsDic!["usetime"] = useTimeAdd //用时
        finalParamsDic!["machinetype"] = tmpCell02!.machineIdTextField.text ?? "未填" // 机器 id
        finalParamsDic!["machinecode"] = tmpCell02!.IMEITextField.text ?? "未填" // IMEI
        
        //        // 服务费用 + 配件费用 = 最终上传
        //        var money: Double = 0.0 //配件费用
        //        for index in 0..<productInfoArr.count {
        //
        //            if productInfoArr[index].price != nil && productInfoArr[index].numbers != nil {
        //                let perPrice = Double(productInfoArr[index].price!) ?? 0.0 // 单价
        //                let nums = Double(productInfoArr[index].numbers!) ?? 0.0 // 数量
        //                money = money + perPrice * nums
        //
        //            }
        //
        //        }
        //
        //        if let fee = tmpCell02!.ServiceFeeTextField.text{
        //            if let df = Double(fee) {
        //                finalParamsDic!["money"] = "\(money + df)"
        //            }else{
        //               finalParamsDic!["money"] = "\(money)"
        //            }
        //
        //        }else{
        //            finalParamsDic!["money"] = "\(money)"
        //        }
        
        
        finalParamsDic!["payWay"] = payWayCell!.payWay
        finalParamsDic!["ServiceCode"] = tmpCell02!.throughTrainTextField.text ?? "未填"
        finalParamsDic!["machineVersion"] = tmpCell02!.machineIdTextField.text ?? "未填"
        
        finalParamsDic!.setValue(initWithDict(productInfoArr), forKey: "products")
        
        return true
    }
    
    func mergerCell03() -> Bool{
        
        guard !(tmpCell03!.selectDayButton.currentTitle! as NSString).isEqual(to: "选择日期") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达日期")
            
            return false
        }
        
        guard !(tmpCell03!.selectTimeButton.currentTitle! as NSString).isEqual(to: "选择时间") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达确切时间")
            
            return false
        }
        
        finalParamsDic!["arrivetime"] = tmpCell03!.selectDayButton.currentTitle! + tmpCell03!.selectTimeButton.currentTitle! // 到达时间
        
        guard !(tmpCell03!.selectWorkTimeButton.currentTitle! as NSString).isEqual(to: "选择用时") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择工作用时")
            
            return false
        }
        
        finalParamsDic!["usetime"] = useTimeAdd //用时
        finalParamsDic!["machinetype"] = tmpCell03!.machineIdTextField.text ?? "未填" // 机器 id
        finalParamsDic!["machinecode"] = tmpCell03!.IMEITextField.text ?? "未填" // IMEI
        
        //        // 服务费用 + 配件费用 = 最终上传
        //        var money: Double = 0.0 //配件费用
        //        for index in 0..<productInfoArr.count {
        //
        //            if productInfoArr[index].price != nil && productInfoArr[index].numbers != nil {
        //                let perPrice = Double(productInfoArr[index].price!) ?? 0.0 // 单价
        //                let nums = Double(productInfoArr[index].numbers!) ?? 0.0 // 数量
        //                money = money + perPrice * nums
        //
        //            }
        //
        //        }
        //        if let fee = tmpCell03!.ServiceFeeTextField.text{
        //            if let df = Double(fee) {
        //                finalParamsDic!["money"] = "\(money + df)"
        //            }else{
        //                finalParamsDic!["money"] = "\(money)"
        //            }
        //
        //        }else{
        //            finalParamsDic!["money"] = "\(money)"
        //        }
        
        finalParamsDic!["payWay"] = payWayCell!.payWay
        finalParamsDic!["ServiceCode"] = tmpCell03!.throughTrainTextField.text ?? "未填"
        finalParamsDic!["machineVersion"] = tmpCell03!.machineIdTextField.text ?? "未填"
        
        finalParamsDic!.setValue(initWithDict(productInfoArr), forKey: "products")
        
        return true
        
    }
    
    func mergerCell04() -> Bool{
        
        guard !(tmpCell04!.selectDayButton.currentTitle! as NSString).isEqual(to: "选择日期") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达日期")
            
            return false
        }
        
        guard !(tmpCell04!.selectTimeButton.currentTitle! as NSString).isEqual(to: "选择时间") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择到达确切时间")
            
            return false
        }
        
        finalParamsDic!["arrivetime"] = tmpCell04!.selectDayButton.currentTitle! + tmpCell04!.selectTimeButton.currentTitle! // 到达时间
        
        guard !(tmpCell04!.selectWorkTimeButton.currentTitle! as NSString).isEqual(to: "选择用时") else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "请选择工作用时")
            
            return false
        }
        
        finalParamsDic!["usetime"] = useTimeAdd //用时
        finalParamsDic!["machinetype"] = tmpCell04!.machineIdTextField.text ?? "未填" // 机器 id
        finalParamsDic!["machinecode"] = tmpCell04!.IMEITextField.text ?? "未填" // IMEI
        
        //        // 服务费用 + 配件费用 = 最终上传
        //        var money: Double = 0.0 //配件费用
        //        for index in 0..<productInfoArr.count {
        //
        //            if productInfoArr[index].price != nil && productInfoArr[index].numbers != nil {
        //                let perPrice = Double(productInfoArr[index].price!) ?? 0.0 // 单价
        //                let nums = Double(productInfoArr[index].numbers!) ?? 0.0 // 数量
        //                money = money + perPrice * nums
        //            }
        //
        //        }
        //        if let fee = tmpCell04!.ServiceFeeTextField.text{
        //            if let df = Double(fee) {
        //                finalParamsDic!["money"] = "\(money + df)"
        //            }else{
        //                finalParamsDic!["money"] = "\(money)"
        //            }
        //
        //        }else{
        //            finalParamsDic!["money"] = "\(money)"
        //        }
        
        finalParamsDic!["payWay"] = payWayCell!.payWay
        finalParamsDic!["ServiceCode"] = tmpCell04!.throughTrainTextField.text ?? "未填"
        finalParamsDic!["machineVersion"] = tmpCell04!.machineIdTextField.text ?? "未填"
        
        finalParamsDic!.setValue(initWithDict(productInfoArr), forKey: "products")
        
        return true
    }
    
    // 对不同 cell 添加特有的 key
    func mergePrivateParam() -> Bool{
        
        switch currentTag { // 根据不同的 cell 获取内容
        case 1:
            return mergerPrivate01()
        case 2:
            return mergerPrivate02()
        case 3:
            return mergerPrivate03()
        case 4:
            return mergerPrivate04()
        default:
            break
        }
        
        return true
        
    }
    
    func mergerPrivate01() -> Bool{
        
        // 没有新的
        
        return true
    }
    
    func mergerPrivate02() -> Bool{
        
        //维护维修
        finalParamsDic!["ResidualSZ"] = tmpCell02!.leftWaterTextField.text ?? "未填" // 剩余水值
        finalParamsDic!["SZunit"] = tmpCell02!.selectUnitButton.currentTitle ?? "天" // 剩余水值的单位
        finalParamsDic!["Y_TDS"] = tmpCell02!.yTDSTextField.text ?? "未填" // 源水 TDS
        finalParamsDic!["Z_TDS"] = tmpCell02!.hTDSTextField.text ?? "未填" // 活水 TDS
        finalParamsDic!["Solution"] = tmpCell02!.responsiblityTextField.text ?? "未填" // 责任归属
        finalParamsDic!["Fault"] = tmpCell02!.reasonButton.currentTitle ?? "未填" // 故障原因
        finalParamsDic!["Solution"] = tmpCell02!.methodButton.currentTitle ?? "未填" // 解决办法
        finalParamsDic!["remark"] = "未填" // 解决办法详细
        
        return true
        
    }
    
    func mergerPrivate03() -> Bool{
        // 安装
        finalParamsDic!["ContractCode"] = tmpCell03!.codeTextField.text ?? "未填" // 合同编号
        
        if (tmpCell03!.selectRentButton.currentTitle! as NSString).isEqual(to: "选择有效期") {
            
            //            let alert = SCLAlertView()
            //            alert.addButton("确定", action: {})
            //            alert.showError("提示", subTitle: "请选择租赁有效期")
            
            //   return false
        }else{
            finalParamsDic!["EffectiveDate"] = tmpCell03!.selectRentButton.currentTitle! //租赁有效期
        }
        finalParamsDic!["Y_TDS"] = tmpCell03!.iyTDSTextField.text ?? "未填" // 源水
        finalParamsDic!["Z_TDS"] = tmpCell03!.ihTDSTextField.text ?? "未填" // 活水
        finalParamsDic!["ShuiYa"] = tmpCell03!.waterpressTextField.text ?? "未填" // 水压
        finalParamsDic!["OpenAudit"] = tmpCell03!.openBoxTextField.text ?? "未填" // 开箱状态
        
        return true
        
    }
    
    func mergerPrivate04() -> Bool{
        //退货
        finalParamsDic!["Cause"] = tmpCell04!.returnTextField.text ?? "未填" // 退货原因
        
        return true
    }
    
    func  initWithDict(_ arr:[ProductInfo])->NSArray{
        let array = NSMutableArray()
        var i = 0
        for item in arr {
            
            let dic = NSMutableDictionary()
            dic.setValue(item.id, forKey: "ProductID")
            dic.setValue(item.image, forKey: "image")
            //        dic.setValue(item.name, forKey: "name")
            dic.setValue(item.price, forKey: "Price")
            //        dic.setValue(item.productCode, forKey: "productCode")
            //        dic.setValue(item.productType, forKey: "productType")
            dic.setValue(item.company, forKey: "CompanyName")
            //  dic.setValue(numberOfRow.objectForKey("\(i)"), forKey: "ProductNum")
            dic.setValue(productInfoArr[i].numbers, forKey: "ProductNum")
            dic.setValue(orderDetail?.id, forKey: "RepairID")
            //        //先给个定值的创建时间
            //        dic.setValue("2011年-4月-3日 05:34:42", forKey: " CreateTime")
            array.add(dic)
            i += 1
        }
        return array
    }
    
    // 拼接其他费用上传字段
    func initOtherFeeDic() -> NSArray{
        
        let array = NSMutableArray()
        var i = 0
        for (index, value) in otherFeeTitleArray.enumerated() {
            
            let dic = NSMutableDictionary()
            dic.setValue(value, forKey: "title")
            dic.setValue(otherFeeArray[index], forKey: "money")
            dic.setValue("浩优服务家", forKey: "remark")
            
            array.add(dic)
            i += 1
        }
        return array
    }
    
    
    // 统计费用
    func statisticsTotalFee(){
        
        // **************************************
        // 显示配件费用 + 更新合计费用
        
        //*******************************************************************
        //  配件费用 + 服务费用(未支付) + 加急费(未支付) + 其他费用 = 合计费用(仅做展示)最终上传
        //  配件费用 + 其他费用 = 最终上传
        for index in 0..<productInfoArr.count {
            
            if productInfoArr[index].price != nil && productInfoArr[index].numbers != nil {
                let perPrice = Double(productInfoArr[index].price!) ?? 0.0 // 单价
                let nums = Double(productInfoArr[index].numbers!) // 数量
                money = money + perPrice * nums
                
                uploadMoney = uploadMoney +  perPrice * nums // 需要提交的钱
            }
            
        }
        
        // 配件费用框
        let deviceMoney = String(format: "%.2lf", money)
        feeShowCell?.productsFeeLabel.text = deviceMoney
        
        
        // 获取到的费用
        for (_,value) in payInfos.enumerated() {
            
            if value.PayState == "128000010"{ // 未支付
                
                if value.Money == nil {
                    money = money + 0.00
                }else{
                    money = money + Double(value.Money!/100)
                }
            }
            
        }
        
        //        // 服务费
        //        if feeShowCell?.serviceFeeStatusLabel.text == "未支付"{
        //
        //            let amountSer = Double((feeShowCell?.servicefeeLable.text)!) ?? 0.0
        //            money = money + amountSer
        //        }
        //
        //        // 加急费
        //        if feeShowCell?.speedFeeStatusLabel.text == "未支付" {
        //
        //            let amountSpe = Double((feeShowCell?.speedfeeLabel.text)!) ?? 0.0
        //            money = money + amountSpe
        //        }
        
        // 其他费用
        
        money = money + otherFee
        //        if (feeShowCell?.otherFeeTextField.text != nil) && (feeShowCell?.otherFeeTextField.text != "") {
        //
        //            var showText = feeShowCell?.otherFeeTextField.text!
        //            if feeShowCell!.otherFeeTextField.text!.hasPrefix(".") {
        //                showText = "0" + showText!
        //            }
        //
        //            if feeShowCell!.otherFeeTextField.text!.hasSuffix(".") {
        //                showText = showText! + "00"
        //            }
        //
        //            let amountOth =  Double(showText!) ?? 0.00
        //            money = money + amountOth
        //            uploadMoney = uploadMoney + amountOth // 需要提交的钱
        //        }
        
        // 合计框显示 + 放入提交参数
        let totalPrice = String(format: "%.2lf", money)
        payWayCell?.totalFeeLabel.text = totalPrice
        
        
        guard let _ = payWayCell else{
            return
        }
        // 重新计算数目之后 payWayCell 的提示文字要重新刷新
        updateUI()
        
    }
    
}

// MARK: - Event response - 按钮/手势等事件的回应方法

extension  SubmitController{
    
    // 返回
    func disMissBtn(){
        
        // 返回前先删除选中的配件信息
        var idarr=[NSString]()
        if productInfoArr.count>0{
            for (_, value) in productInfoArr.enumerated(){
                
                guard let _ = value.id else {
                    return
                }
                idarr.append(value.id! as NSString)
            }
            for _ in 0...productInfoArr.count-1 {
                
                ProductInfo.deleteCachedObjectsWithID(idarr)
            }}
        
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // 选择其他费用类型
    func selectOtherFee(){
        
        let selectOtherFeeTypeVC = RNSelectOtherFeeTypeViewController(selectedTitle: otherFeeTitleArray, selectedFees: otherFeeArray) { (result) in
            self.otherFeeTitleArray.removeAll()
            self.otherFeeArray.removeAll()
            
            self.otherFee = 0.0 // 置零
            
            for item in result{
                
                self.otherFeeTitleArray.append(item.0)
                self.otherFeeArray.append(item.1)
                
                self.otherFee = self.otherFee + item.1
                
            }
            
            self.money = 0 // 置零
            self.statisticsTotalFee()
            
            self.tableView.reloadData()
            
        }
        navigationController?.pushViewController(selectOtherFeeTypeVC, animated: true)
    }
    
    // 更换图片
    func exchangePicture(longPress: UILongPressGestureRecognizer){
        
        if longPress.state == UIGestureRecognizerState.began {
            weak var weakSelf = self
            let alert = SCLAlertView()
            alert.addButton("相册") {
                let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: true) {  image, asset in
                    
                    if image != nil{
                        
                        let imgView = longPress.view as! RNUploadImageView
                        imgView.image = image
                        
                    }
                    weakSelf?.dismiss(animated: true, completion: nil)
                    
                }
                
                weakSelf?.present(libraryViewController, animated: true, completion: nil)
            }
            
            alert.addButton("拍摄") {
                let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) {  image, asset in
                    
                    if image != nil{
                        let imgView = longPress.view as! RNUploadImageView
                        imgView.image = image
                    }
                    weakSelf?.dismiss(animated: true, completion: nil)
                    
                    
                }
                weakSelf?.present(cameraViewController, animated: true, completion: nil)
            }
            alert.addButton("取消", action: {})
            alert.showInfo("更换图片", subTitle: "请选择获取图片方式")
            
        }
        
    }
    
    
}

// MARK: - Delegates - 即各种代理方法

// MARK: - OznerScanViewControllerDelegate

extension SubmitController: OznerScanViewControllerDelegate{
    
    // 扫描二维码回调
    func popToSubmitCon(_ result: String) {
        
        if scanWhichTextFied == "3" {
            self.idScanResult  = result
        }
        else if scanWhichTextFied == "4"
        {
            self.imeiScanResult = result
        }
        else{
            
            self.throghtTrainScanResult = result
        }
        self.tableView.reloadData()
        
    }
}

// MARK: - SubmitCellDelegate

extension SubmitController: SubmitCellDelegate{
    
    func poptoSuperCon(_ label1: String)  {
        
        UsefulPickerView.showMultipleColsPicker("选择用时", data: useTimeData, defaultSelectedIndexs: [0,0]) {[unowned self] (selectedIndexs, selectedValues) in
            
            var temp = ""
            for (index ,value) in selectedValues.enumerated(){
                
                temp.append(value)
                
                let str = value as NSString
                let time = str.substring(to: str.length-2)
                if index == 0 {
                    
                    self.useTimeAdd = self.useTimeAdd + Int(time)!*60
                }else{
                    self.useTimeAdd = self.useTimeAdd + Int(time)!
                }
            }
            
            self.useTimeShow = temp
            
            
            self.tableView.reloadData()
        }
        
    }
    
    
    func popAboutScanToSuperCon(_ whichLabel: String) {
        
        scanWhichTextFied = whichLabel // 对应的 textField 的 tag 101机器id - 102IMEI - 103直通车
        
        // 跳转到扫描二维码界面
        let  scan = OznerScanViewController()
        scan.delegate = self
        self.navigationController?.pushViewController(scan, animated: true)
    }
    
    //上传相册
    func uploadPhoto(_ press: UITapGestureRecognizer) {
        
        //        let tmpSubmitcell: SubmitCell!
        //        switch tag {
        //        case 10:
        //            tmpSubmitcell = tmpCell01
        //        case 11:
        //            tmpSubmitcell = tmpCell02
        //        case 12:
        //            tmpSubmitcell = tmpCell03
        //        case 13:
        //            tmpSubmitcell = tmpCell04
        //        default:
        //            break
        //        }
        
        weak var weakSelf = self
        if tmpIndex<204 {
            let alert = SCLAlertView()
            alert.addButton("相册") {
                let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: true) {  image, asset in
                    
                    if image != nil{
                        self.tmpIndex += 1
                        
                        let imageView = weakSelf?.tableView.viewWithTag((self.tmpIndex)) as! RNUploadImageView
                        
                        if image != nil {
                            
                            imageView.image = image
                            // imageView.isUserInteractionEnabled = false
                            imageView.isUploaded = true
                            
                            // 上传成功后给 imageView 添加长按手势用来更换照片
                            let longTap =  UILongPressGestureRecognizer(target: self, action: #selector(self.exchangePicture(longPress:)))
                            imageView.addGestureRecognizer(longTap)
                            longTap.minimumPressDuration = 1.0
                            
                            if self.tmpIndex < 203 {
                                
                                let imageView = weakSelf?.tableView.viewWithTag((self.tmpIndex+1)) as! RNUploadImageView
                                imageView.image = UIImage(named: "addmore")
                                imageView.isHidden = false
                            }
                            else{
                            }
                        }
                        
                    }
                    weakSelf?.dismiss(animated: true, completion: nil)
                    
                }
                
                weakSelf?.present(libraryViewController, animated: true, completion: nil)
            }
            
            alert.addButton("拍摄") {
                let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) {  image, asset in
                    
                    if image != nil{
                        self.tmpIndex += 1
                        
                        let imageView = weakSelf?.tableView.viewWithTag((self.tmpIndex)) as! RNUploadImageView
                        imageView.image = image
                        
                        //  imageView.isUserInteractionEnabled = false
                        imageView.isUploaded = true
                        
                        if self.tmpIndex < 203 {
                            
                            let imageView = weakSelf?.tableView.viewWithTag((self.tmpIndex+1)) as! RNUploadImageView
                            
                            imageView.image = UIImage(named: "addmore")
                            imageView.isHidden = false
                        }
                        else{
                        }
                    }
                    weakSelf?.dismiss(animated: true, completion: nil)
                    
                    
                }
                weakSelf?.present(cameraViewController, animated: true, completion: nil)
            }
            alert.addButton("取消", action: {})
            alert.showInfo("选择上传照片", subTitle: "请选择获取图片方式")
            
            
        }
        
    }
    
    func popToSelectProductMaterial() {
        
        let selectProductMaterial = SelectProductViewController(isSignArr: self.isSignArr, productinfos: self.productinfos)
        
        self.navigationController?.pushViewController(selectProductMaterial, animated: true)
        selectProductMaterial.delegate = self
    }
    
    func reloadTableView() {
        
        //        tableView.setNeedsLayout()
        //        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    
    func linkBluetooth() {
        
        // 连接蓝牙
        let pairingVC = RNPairingViewController(nibName: "RNPairingViewController", bundle: nil) { (isLinkedBluetooth) in
        
            self.isLinkedBluetooth = isLinkedBluetooth
            
            print(self.isLinkedBluetooth)
        }
        pairingVC.orderDetail = self.orderDetail
        self.navigationController?.pushViewController(pairingVC, animated: true)
    }
}


// MARK: - SubmitBtnDelegate

extension SubmitController: SubmitBtnDelegate{
    
    func submitToServer() {
        
        //        let payViewController = RNPayViewController(nibName: "RNPayViewController", bundle: nil)
        //        navigationController?.pushViewController(payViewController, animated: true)
        
        if !isLinkedBluetooth {
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "必须连接蓝牙修复水值")
            
            return
        }
        
        // 判断是否选择了支付方式
        if payWayCell?.selectedIndex == 0{
            
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "必须选择支付方式")
            
            return
        }
        
        guard mergePublicParams() else{
            return
        }
        
        imageDic = NSMutableDictionary()
        guard imageDic != nil else{
            return
        }
        
        // 必填参数:
        // - finalParamsDic!["money"] = "\(money)" // 总金额
        // - finalParamsDic!["usetime"] = useTimeAdd // 选择用时
        // - finalParamsDic!["payWay"] = feeShowCell!.payWay // 支付方式
        // - finalParamsDic!["arrivetime"] = tmpCell01!.selectDayButton.currentTitle! + tmpCell01!.selectTimeButton.currentTitle! // 到达时间
        if !mergePrivateParam(){
            return
        }
        
        // TODO: -  参数变化
        // 必要入参
        finalParamsDic!["money"] = "\(uploadMoney)"
        finalParamsDic!.setValue(initOtherFeeDic(), forKey: "moneylist")
        
        guard tmpIndex >= 201 else {
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showError("提示", subTitle: "至少需要上传一张机器安装图和一张机器安装确认单的照片")
            
            return
        }
        
        // 上传经纬度
        if !mergeLongitudeAndLatitude(){
            return
        }
        
        let tmpParam = NSMutableDictionary()
        
        do{
            let data = try JSONSerialization.data(withJSONObject: finalParamsDic!, options: .prettyPrinted)
            
            let str  = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            tmpParam.setValue(str, forKey: "data")
            for index in 199..<tmpIndex{
                
                let imageView  =  self.tableView.viewWithTag(index+1) as! UIImageView
                if imageView.image != nil{
                    
                    let image = imageView.image
                    let  imageData:Data = UIImageJPEGRepresentation(image!, 0.001)!
                    
                    imageDic!.setValue(imageData, forKey: "pic"+"\(index)")
                    
                }
                else{
                    //let alertView=SCLAlertView()
                    //                    alertView.addButton("ok", action: {})
                    //                    alertView.showError("错误提示", subTitle: "") //
                }
                
            }
            
            
        }catch let error as NSError{
            
            print(error)
            
        }
        
        palatteDic = NSMutableDictionary()
        if let palatte = myPaletteInfo.1{
            let  imageData:Data = UIImageJPEGRepresentation(palatte, 0.001)!
            palatteDic!.setValue(imageData, forKey: "autograph")
            
        }else{
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "尚未签名,请签名")
            
            return
        }
        
        let params = tmpParam as NSMutableDictionary
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.FinshOrder(params, imageDic: imageDic!, palatte: palatteDic!, success: { [weak self] (payState) in
            MBProgressHUD.hide(for: self?.view, animated: true)
            
            if payState == 2 { // 状态为2时跳转支付界面
                
                let payViewController = RNPayViewController(orderId: self?.orderDetail?.id)
                self?.navigationController?.pushViewController(payViewController, animated: true)
                
            }else{  //状态为2时结单成功
                
                
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: { [weak self] in
                    
                    self?.skipToRobOneVC() // 跳转控制器
                })
                alertView.showSuccess("提示", subTitle: "结单成功")
            }
            
            
            
        }) { (error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertView=SCLAlertView()
            alertView.addButton("ok", action: {})
            alertView.showError("提示", subTitle: error.localizedDescription)
            
            
        }
        
    }
    
}

// MARK: - SelectProductViewControllerDelegate

extension SubmitController: SelectProductViewControllerDelegate{
    
    // 选择配件信息回调
    func selectedInfos(_ productInfo: [Int:ProductInfo],isSign:[Bool]) {
        
        if (productInfo.count != 0){
            //  for (key,value) in productInfo {
            
            self.productinfos=productInfo
            
            
            //  }
            self.productInfoArr.removeAll()
            for (_,value) in self.productinfos {
                
                value.numbers = 1
                self.productInfoArr.append(value)
                
                
            }
            if (productInfoArr.count != 0){
                //   for index in 0...productInfoArr.count-1 {
                
                //   }
            }
        }
        else
        {
            
            self.productInfoArr = [ProductInfo]()
            self.productinfos=[Int:ProductInfo]()
            
        }
        self.isSignArr=isSign
        //设置section刷新第二个section
        let section = IndexSet(integer: 1)
        self.tableView.reloadSections(section, with: .automatic)
        
        money = 0.0 // 至0
        // 统计费用
        self.statisticsTotalFee()
    }
    
}


// MARK: - SubmitListsCellDelegate

extension SubmitController: SubmitListsCellDelegate{
    
    func pushNumbersToCon(_ numbers: Int,row : Int) {
        
        productInfoArr[row].numbers=numbers as NSNumber?
        
        self.money = 0.0 // 置0
        self.uploadMoney = 0.0 //置0
        // 统计费用
        self.statisticsTotalFee()
    }
}

// MARK: - RNPaywayTableViewCellDelegate
extension SubmitController: RNPaywayTableViewCellDelegate{
    
    func updateUI() {
        
        let serviceFee = payWayCell!.totalFeeLabel.text!
        
        if payWayCell?.payWay == "124010020" {
            payWayCell?.payDecLabel.text = "稍后客户要在微信端支付\(serviceFee),请跟进支付进度"
        }else if payWayCell?.payWay == "124020040"{
            payWayCell?.payDecLabel.text = "确认已收到客户现金支付\(serviceFee),需要提交给公司\(serviceFee)"
            
        }else if payWayCell?.payWay == "124010040"{
            payWayCell?.payDecLabel.text = "客户不需要支付费用"
        }else if payWayCell?.payWay == "124010001"{
            payWayCell?.payDecLabel.text = "已在Pos机上刷卡进行支付"
        }else{
            payWayCell?.payDecLabel.text = ""
        }
        
        
        self.tableView.reloadData()
    }
}




// MARK: - UITableViewDelegate && UITableViewDatasource

extension SubmitController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of row
        
        if section == 0{
            return 1
        }
        else  if section == 1
        {
            return productInfoArr.count
        }
        else if section == 3
        {
            return otherFeeTitleArray.count
            
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        if indexPath.section == 1 {
        //            return 84
        //        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 5{
            return 20.0
        }else{
            return 0.01
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 3 {
            return 30
        }else if section == 5{
            return 20.0
        }else{
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 3 {
            let headView = UIView(frame: CGRect(x: 0, y: 0, width: WIDTH_SCREEN, height: 30))
            headView.backgroundColor = UIColor.white
            
            let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 60, height: 30))
            titleLabel.text = "其他费用"
            titleLabel.font =  UIFont.systemFont(ofSize: 14)
            headView.addSubview(titleLabel)
            
            let selectButton = UIButton(frame: CGRect(x: 100, y: 0, width: WIDTH_SCREEN-100-65, height: 30))
            selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            selectButton.titleLabel?.textAlignment = NSTextAlignment.center
            selectButton.setTitle("选择其他费用", for: UIControlState())
            selectButton.setTitleColor(COLORRGBA(0, g: 184, b: 252, a: 1), for: UIControlState())
            selectButton.addTarget(self, action: #selector(selectOtherFee), for: UIControlEvents.touchUpInside)
            headView.addSubview(selectButton)
            
            return headView
        }else{
            return nil
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        cell?.selectionStyle = .none
        
        
        if indexPath.section == 0 {
            
            let base01:Set<String> = ["充水","水质检测","送货"]
            let base02:Set<String> = ["退货","移机","换货","换芯"]
            let base03:Set<String> = ["安装"]
            // let base04:Set<String> = ["维护维修"]
            
            if let type = orderDetail?.troubleHandleType{
                if base01.contains(type) {
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitCell01") as! RNSubmitCell01
                    tmpCell01 = cell as? RNSubmitCell01
                    tmpCell01!.delegate = self
                    
                    currentTag = 1 // 标记当前的 cell 便于提交时获取数据
                    
                    tmpCell01!.selectWorkTimeButton.setTitle(useTimeShow, for: UIControlState())
                    
                    // 扫描结果显示
                    if idScanResult != "data is empty" {
                        tmpCell01!.machineIdTextField.text = idScanResult
                    }
                    if imeiScanResult != "data is empty" {
                        tmpCell01!.IMEITextField.text = imeiScanResult
                    }
                    if throghtTrainScanResult != "data is empty" {
                        tmpCell01!.throughTrainTextField.text = throghtTrainScanResult
                    }
                    
                    tmpCell01?.configCell(faultReasons, dealMethods: dealMethods, orderDetail: orderDetail!)
                    
                }else if base02.contains(type){
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitCell04") as! RNSubmitCell04
                    tmpCell04 = cell as? RNSubmitCell04
                    tmpCell04!.delegate = self
                    
                    currentTag = 4 // 标记当前的 cell 便于提交时获取数据
                    
                    tmpCell04!.selectWorkTimeButton.setTitle(useTimeShow, for: UIControlState())
                    
                    // 扫描结果显示
                    if idScanResult != "data is empty" {
                        tmpCell04!.machineIdTextField.text = idScanResult
                    }
                    if imeiScanResult != "data is empty" {
                        tmpCell04!.IMEITextField.text = imeiScanResult
                    }
                    if throghtTrainScanResult != "data is empty" {
                        tmpCell04!.throughTrainTextField.text = throghtTrainScanResult
                    }
                    
                    
                    if type == "换货" && sectionCount == 2 {
                        tmpCell04?.configCell(faultReasons, dealMethods: dealMethods, orderDetail: orderDetail!, isRepair: true)
                    }else{
                        tmpCell04?.configCell(faultReasons, dealMethods: dealMethods, orderDetail: orderDetail!, isRepair: false)
                    }
                    
                    
                }else if base03.contains(type){
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitCell03") as! RNSubmitCell03
                    tmpCell03 = cell as? RNSubmitCell03
                    tmpCell03!.delegate = self
                    
                    currentTag = 3 // 标记当前的 cell 便于提交时获取数据
                    
                    tmpCell03!.selectWorkTimeButton.setTitle(useTimeShow, for: UIControlState())
                    
                    // 扫描结果显示
                    if idScanResult != "data is empty" {
                        tmpCell03!.machineIdTextField.text = idScanResult
                    }
                    if imeiScanResult != "data is empty" {
                        tmpCell03!.IMEITextField.text = imeiScanResult
                    }
                    if throghtTrainScanResult != "data is empty" {
                        tmpCell03!.throughTrainTextField.text = throghtTrainScanResult
                    }
                    
                    tmpCell03?.configCell(faultReasons, dealMethods: dealMethods, orderDetail: orderDetail!)
                    
                }else{ // 维护维修
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitCell02") as! RNSubmitCell02
                    tmpCell02 = cell as? RNSubmitCell02
                    tmpCell02!.delegate = self
                    
                    currentTag = 2 // 标记当前的 cell 便于提交时获取数据
                    
                    tmpCell02!.selectWorkTimeButton.setTitle(useTimeShow, for: UIControlState())
                    
                    // 扫描结果显示
                    if idScanResult != "data is empty" {
                        tmpCell02!.machineIdTextField.text = idScanResult
                    }
                    if imeiScanResult != "data is empty" {
                        tmpCell02!.IMEITextField.text = imeiScanResult
                    }
                    if throghtTrainScanResult != "data is empty" {
                        tmpCell02!.throughTrainTextField.text = throghtTrainScanResult
                    }
                    
                    
                    if sectionCount == 2 {
                        tmpCell02?.configCell(faultReasons, dealMethods: dealMethods, orderDetail: orderDetail!, isRepair: true)
                    }else{
                        tmpCell02?.configCell(faultReasons, dealMethods: dealMethods, orderDetail: orderDetail!, isRepair: false)
                    }
                    
                }
            }
            
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
        }else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SubmitListsCell") as! SubmitListsCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
            let tmpcell = cell as! SubmitListsCell
            tmpcell.delegate=self
            
            
            if productInfoArr[indexPath.row].numbers != nil {
                tmpcell.showText(self.productInfoArr[indexPath.row], row: indexPath.row,number:self.productInfoArr[indexPath.row].numbers!)
            }
            
            
        }else if indexPath.section == 2{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNFeeShowCell", for: indexPath) as! RNFeeShowCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
            feeShowCell = cell as? RNFeeShowCell
            // feeShowCell!.delegate = self
            
            feeShowCell?.configCell(orderDetail!, payInfos: self.payInfos)
        }
        else if indexPath.section == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNOtherFeeTableViewCell", for: indexPath) as! RNOtherFeeTableViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
            otherFeeCell = cell as? RNOtherFeeTableViewCell
            
            if otherFeeTitleArray.count > indexPath.row {
                otherFeeCell?.configCell(otherFeeTitleArray[indexPath.row], money: otherFeeArray[indexPath.row], index: indexPath)
            }
            
            
        }else if indexPath.section == 4{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNPaywayTableViewCell", for: indexPath) as! RNPaywayTableViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
            payWayCell = cell as? RNPaywayTableViewCell
            payWayCell?.delegate = self
            
        }else if indexPath.section == 5{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSignerTableViewCell", for: indexPath) as! RNSignerTableViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            signerCell = cell as? RNSignerTableViewCell
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "SubmitBtn", for: indexPath) as! SubmitBtn
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
            let tmpcell = cell as! SubmitBtn
            tmpcell.delegate=self
            
            
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 5 {
            let paletteVC = RNPaletteViewController(callBack:{ paletteInfo in
                
                self.myPaletteInfo = paletteInfo
                
                DispatchQueue.main.async { // 回主线程更新 UI
                    
                    if let signImage = paletteInfo.1{
                        
                        //                        // 渐进显示
                        //                        let transition = CATransition()
                        //                        transition.type = kCATransitionFade
                        //                        transition.duration = 0.3
                        //                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        //                        self.signerCell?.signerImageView.layer.add(transition, forKey: nil)
                        
                        self.signerCell?.signerImageView.image = signImage
                    }else{
                        
                        
                        self.signerCell?.signerImageView.image = UIImage(named:"addmore") // 清空签名
                        self.myPaletteInfo = (false, nil)
                    }
                    
                }
            })
            
            if myPaletteInfo.0 {
                paletteVC.paletteImage = self.signerCell?.signerImageView.image
            }else{
                paletteVC.paletteImage = nil
            }
            
            navigationController?.pushViewController(paletteVC, animated: true)
            
        }
    }
    
    
}


// 定位

extension SubmitController: CLLocationManagerDelegate{
    // 定位
    
    func myLocationManager(){
        
        manager = CLLocationManager()
        manager!.delegate=self
        manager!.desiredAccuracy = kCLLocationAccuracyBest
        manager!.distanceFilter = 1000.0 //每隔多少米定位一次（这里的设置为任何的移动
        
        //        if #available(iOS 8.0, *) {
        //           manager!.requestAlwaysAuthorization()
        //        }
        manager!.requestAlwaysAuthorization()
        
        // ios9 允许设备后台定位（ios9后新特性，同一个设备，允许多个loaction manager,一些只能再前台定位，一些可以在后台定位）
        //        if #available(iOS 9.0, *) {
        //            manager?.allowsBackgroundLocationUpdates = true
        //        }
        
        if CLLocationManager.locationServicesEnabled() { // 系统定位服务是否开启
            manager!.startUpdatingLocation()
        }else{
            
            self.noticeError("定位服务未打开，请修改手机设置(设置->浩优服务家->位置->始终)", autoClear: true, autoClearTime: 3)
        }
        
        
    }
    
    // 准备经纬度参数
    func mergeLongitudeAndLatitude() -> Bool{
        if CLLocationManager.locationServicesEnabled() { // 系统定位服务是否开启
            
            if (CLLocationManager.authorizationStatus().rawValue == 0) || (CLLocationManager.authorizationStatus().rawValue == 3) {
                
                if let long = myLongtitude, let lati = myLatitude {
                    finalParamsDic!["arrivelongitude"] = long
                    finalParamsDic!["arrivelatitude"] = lati
                    return true
                }else{
                    
                    self.noticeError("正在获取位置信息,请稍等", autoClear: true, autoClearTime: 3)
                    return false
                }
                
            }else{
                
                
                self.noticeError("服务家定位服务未打开，请修改手机设置(设置->浩优服务家->位置->始终)", autoClear: true, autoClearTime: 3)
                
                return false
            }
        }else{
            
            
            self.noticeError("系统定位服务未打开", autoClear: true, autoClearTime: 3)
            
            return false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0]
        let o2d = newLocation.coordinate
        //CLLocationCoordinate2D
        //        let loca = 31.4217987560
        //        let logn = 116.7258979197
        //        let  location = CLLocation.init(latitude: loca, longitude: logn)
        
        //let o2d = newLocation.coordinate
        // manager.stopUpdatingLocation() // 停止定位后，当位置发生移动，didUpdateLocations这个代理再调用
        
        myLatitude = (o2d.latitude as NSNumber).stringValue
        myLongtitude = (o2d.longitude as NSNumber).stringValue
        
        self.isLocationSuccess = true
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { // 定位失败调用的代理方法
        
        isLocationSuccess = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        if status.rawValue == 0 || status.rawValue == 3 {
            // isLocationSuccess = true
            
            manager.startUpdatingLocation()
        }
    }
    
    
}

