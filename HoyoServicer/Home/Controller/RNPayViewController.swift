//
//  RNPayViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/9/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import MBProgressHUD


class RNPayViewController: UIViewController {
    
//    // 单例
//    private static let sharedInstance = RNPayViewController()
//    class var sharedManager: RNPayViewController {
//        return sharedInstance
//    }

    @IBOutlet weak var orderIdLabel: UILabel! // 订单标号
    @IBOutlet weak var orderNameLabel: UILabel! // 订单名称
    
    
    @IBOutlet weak var feeDetailView: UIView! // 费用的详细
    
    @IBOutlet weak var totalFeeLabel: UILabel! // 合计
    @IBOutlet weak var weixinButton: UIButton! // 选择微信支付按钮
    @IBOutlet weak var alipayButton: UIButton! // 选择支付宝支付
    @IBOutlet weak var payButton: UIButton! // 立即支付按钮
    
    var isSelectedPayWay = true // 是否选择了支付方式 ,必选
    var selectedIndex = 0 // 选择索引
    
    var payInfos = [RNPAYDetailModel]() // 支付类型信息
    var orderId: String? // 订单 id
    var payOrderModel: RNPayOrderModel?  // 待支付订单 model
    var weixinModel: RNWeixinModel? // 微信支付model
    var alipayModel: AlipayOrder? // 支付宝支付 model
    
    var privateKey = "t12dnxuhhvgs4c2gmes2c7abb47oyfj7" // 私钥
    var mySign = "" //自己生成签名-未md5加密
    
    var endSign = "" // 最终签名
    
    var isNeedPay = 1 // 后台返回的,是否需要支付,0不需要支付
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //dissCall不等于nil，是从注册跳过来的，否则，从个人中心过来的
    convenience  init(orderId: String?) {
        
        var nibNameOrNil = String?("ListsDetailViewController.swift")
        if Bundle.main.path(forResource: nibNameOrNil, ofType: "xib") == nil
        {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
        
        self.orderId = orderId
        
    }
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        navigationItem.title = "选择付款"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("back", target: self, action: #selector(disMissBtn))
        
        
        downloadDataWithNoPayInfo() // 获取未支付订单信息
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(weixinSuccessAction), name: NSNotification.Name(rawValue: "WEIXINPAYSUCCESS"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(weixinFailAction), name: NSNotification.Name(rawValue: "WEIXINPAYFAIL"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{

        // 移除通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATEWAITORDER"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WEIXINPAYSUCCESS"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WEIXINPAYFAIL"), object: nil)
    }

}

// MARK: - custom methods
extension String {
    var md5 : String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);
        
        CC_MD5(str!, strLen, result);
        
        let hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        result.deinitialize();
        
        return String(format: hash as String)
    }
}

extension RNPayViewController{
    
    // 生成签名
    func generateSign(){
        
        if weixinModel?.appid != nil {
            mySign = mySign + "appid=\(weixinModel!.appid)&"
        }
        
        if weixinModel?.noncestr != nil {
            mySign = mySign + "noncestr=\(weixinModel!.noncestr)&"
        }
        if weixinModel?.pkg != nil {
            mySign = mySign + "package=\(weixinModel!.pkg)&"
        }
        
        if weixinModel?.partnerid != nil {
            mySign = mySign + "partnerid=\(weixinModel!.partnerid)&"
        }
        if weixinModel?.prepayid != nil {
            mySign = mySign + "prepayid=\(weixinModel!.prepayid)&"
        }
        if weixinModel?.timestamp != nil {
            mySign = mySign + "timestamp=\(weixinModel!.timestamp)&"
        }
        
        mySign = mySign + "key=\(privateKey)"
        
        endSign = mySign.md5.uppercased()
    }
    
    // 跳转控
    func skipToRobOneVC(){
        
        guard let step = self.navigationController?.viewControllers.count else {
            
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
            return
        }
        
        guard step >= 4 else {
            
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
            return
        }
        
        guard let vc = navigationController?.viewControllers[step-4] else {
            let alertView = SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showError("提示", subTitle: "导航栈错误,跳转失败,请手动返回")
            return
        }
        
         NotificationCenter.default.post(name: Notification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 发送通知到ListsDetailViewController让其更新数据
        _ = self.navigationController?.popToViewController(vc, animated: true)

        
//        guard navigationController?.viewControllers != nil else {
//            let alertView=SCLAlertView()
//            alertView.addButton("确定", action: {})
//            alertView.showError("提示", subTitle: "抱歉,获取返回信息,请手动返回")
//            
//            return
//        }
//        
//        for vc in ( navigationController?.viewControllers)! {
//            
//            if vc.isKind(of: RobListOneController.self) || vc.isKind(of: RNWaitPayViewController.self){
//                
//               NotificationCenter.default.post(name: Notification.Name(rawValue: "UPDATEWAITORDER"), object: nil) // 发送通知到ListsDetailViewController让其更新数据
//               let _ =  navigationController?.popToViewController(vc, animated: true)
//            }
//        }

    }
}


// MARK: - private methods

extension RNPayViewController{
    
    // 获取未支付订单信息
    func downloadDataWithNoPayInfo(){
        
        guard orderId != nil else{
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        User.GetOrderNoPayDetails(orderId!, success: { [weak self] (payOrderModel,isNeedPay) in
            
            MBProgressHUD.hide(for: self?.view, animated: true)
            
            self?.payOrderModel = payOrderModel
            self?.payInfos = payOrderModel.payInfos!
            self?.isNeedPay = isNeedPay
            
            self?.updateMyView()
            self?.showInfoOnCurrentView()
            
            }) { (error) in
                
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)
        }
    }
    
    //更新 view
    func updateMyView() {
        
        if isNeedPay == 0{
            return
        }
        
        var lastView: RNFeeTypeView?
        for (index,value) in payInfos.enumerated() {
            
            let newView = Bundle.main.loadNibNamed("RNFeeTypeView", owner: self, options: nil)?.last as! RNFeeTypeView
            
            newView.typeLabel.text = value.PayTitle
            let price = String(format: "%.2f元", value.Money!/100.0)
            newView.priceLabel.text = price
            
            feeDetailView.addSubview(newView)
            
            if lastView == nil {
                newView.snp.makeConstraints({ (make) in
                    make.top.equalTo(5)
                    make.leading.equalTo(0)
                    make.trailing.equalTo(0)
                })
                
                if index == payInfos.count - 1 {
                    newView.snp.makeConstraints({ (make) in
                        make.bottom.equalTo(feeDetailView.snp.bottom).offset(-10)
                    })
                }
            }else{
                
                newView.snp.makeConstraints({ (make) in
                    make.top.equalTo(lastView!.snp.bottom).offset(5)
                    make.leading.equalTo(0)
                    make.trailing.equalTo(0)
                })
                
                if index == payInfos.count - 1 {
                    newView.snp.makeConstraints({ (make) in
                        make.bottom.equalTo(feeDetailView.snp.bottom).offset(-10)
                    })
                }
            }
            
            lastView = newView
            
        }
    }
    
    // 更新 界面信息
    
    func showInfoOnCurrentView(){
        
        if isNeedPay == 0{
            
            orderIdLabel.text = "该订单不需要支付"
            orderNameLabel.text = "该订单不需要支付"
            totalFeeLabel.text = "0.00"
            
            return
        }
        
        orderIdLabel.text = payOrderModel?.orderId ?? "************"
        orderNameLabel.text = payOrderModel?.orderName ?? "未知"
        
        guard payOrderModel?.payMoney != nil else{
            return
        }
        totalFeeLabel.text = String(format: "%.2f", (payOrderModel?.payMoney)!/100.0)
    }
    
}


// MARK: - event response

extension RNPayViewController{
    
    func disMissBtn(){
        
        //  UIApplication.sharedApplication().statusBarHidden = false
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //选择支付方式
    @IBAction func selectPayWay(_ sender: UIButton) {
        
        guard !sender.isSelected else{ // 已是选择状态不做任何操作
            return
        }
        
        if selectedIndex == 0 {
            
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: {})
            alertView.showInfo("提示", subTitle: "支付宝功能暂未开通,请期待下个版本")
            
            return
//            weixinButton.selected = false
//            weixinButton.setImage(UIImage(named: "w_unSelect"), forState: UIControlState.Normal)
        }else{
            alipayButton.isSelected = false
            alipayButton.setImage(UIImage(named: "w_unSelect"), for: UIControlState())
        }
       
        
//        sender.selected = true
//        sender.setImage(UIImage(named: "w_selected"), forState: UIControlState.Normal)
//       
//
//        selectedIndex = sender.tag
        
    }
    
    
    // 立即支付
    @IBAction func payAction(_ sender: UIButton) {
        
//        if !isSelectedPayWay {
//            let alert = SCLAlertView()
//            alert.addButton("确定", action: {})
//            alert.showNotice("提示", subTitle: "您还没选择支付方式")
//
//            return
//        }
        
        if isNeedPay == 0 {
            let alertView=SCLAlertView()
            alertView.addButton("确定", action: { [weak self] in
                
                self?.skipToRobOneVC() // 跳转控制器
                })
            alertView.showInfo("提示", subTitle: "订单不需要支付,返回待处理界面")
            
            return
        }

        guard orderId != nil else{
            return
        }
        
        if selectedIndex == 0{
            
            
        
            User.GetWeixinPayInfos(orderId!, success: { [weak self] (weixinModel) in
                
                self?.weixinModel = weixinModel
                
                self?.generateSign()
                
                self?.weixinPayAction()

                
            }) { (error) in
                let alertView=SCLAlertView()
                alertView.addButton("ok", action: {})
                alertView.showError("提示", subTitle: error.localizedDescription)
            }

           
        }else{
            
            User.GetAlipayPayInfos(orderId!, success: { [weak self](alipayModel) in
                
                self?.alipayModel = alipayModel
                
                self?.alipayAction()
                
                }, failure: { (error) in
                    let alertView=SCLAlertView()
                    alertView.addButton("ok", action: {})
                    alertView.showError("提示", subTitle: error.localizedDescription)
            })
            
            
        }
        
    }
    
    func weixinPayAction(){
        
        if WXApi.isWXAppInstalled(){
            
            let rep = PayReq()
            rep.partnerId = weixinModel?.partnerid
            rep.prepayId = weixinModel?.prepayid
            rep.package = weixinModel?.pkg
            rep.nonceStr = weixinModel?.noncestr
            
            if let timestamp = UInt32((weixinModel?.timestamp)!) {
                rep.timeStamp = timestamp
            }
            
            rep.sign = endSign
            
            
            WXApi.send(rep)
        }else{
            
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showNotice("提示", subTitle: "您尚未安装微信客户端,请先安装")
        }

    }
    
    func alipayAction(){
     
        let alipayUrl = URL(string: "alipay:")
        if UIApplication.shared.canOpenURL(alipayUrl!) {
            
            let appScheme = "HoyoServicer"
            
            let orderInfoEncode = alipayModel!.orderInfoEncoded(true)
//            
//            let signString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, alipayModel!.sign_type as! CFStringRef, "!*'();:@&=+$,/?%#[]" as! CFStringRef, <#T##legalURLCharactersToBeEscaped: CFString!##CFString!#>, <#T##encoding: CFStringEncoding##CFStringEncoding#>)
            //CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
            let signString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, alipayModel!.sign as CFString!, nil, "!*'();:@&=+$,/?%#[]" as CFString!, CFStringBuiltInEncodings.UTF8.rawValue) as String
//            let charactersToEscape = "!*'();:@&=+$,/?%#[]"
//            let allowedCharacters = NSCharacterSet(charactersInString: charactersToEscape).invertedSet
//            let signString = alipayModel!.sign.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
            
            let orderString = String(format: "%@&sign=%@", orderInfoEncode!,signString)
            
            AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { (resultDic) in
                
                print("------------\(resultDic)---------")
            })
            
        }else{
            let alert = SCLAlertView()
            alert.addButton("确定", action: {})
            alert.showNotice("提示", subTitle: "您尚未安装支付宝客户端,请先安装")
            
        }

    }
    
}

// MARK: - WXApiDelegate 微信支付回调通知处理事件

extension RNPayViewController {
    
    func weixinSuccessAction(){
        
        let alert = SCLAlertView()
        alert.addButton("确定", action: { 
            self.skipToRobOneVC() // 跳转控制器
        })
        alert.showSuccess("提示", subTitle: "支付成功")
    }
    
    func weixinFailAction(){
        
        let alert = SCLAlertView()
        alert.addButton("确定", action: {
        
           let _ = self.navigationController?.popViewController(animated: true)
        })
        alert.showNotice("提示", subTitle: "支付失败")
    }
    

}
