
//
//  User.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/4/5.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import SDWebImage

let UserDefaultsUserTokenKey = "usertoken"
let UserDefaultsUserIDKey = "userid"
let CurrentUserDidChangeNotificationName = "CurrentUserDidChangeNotificationName"

class User: DataObject {
    
    // Insert code here to add functionality to your managed object subclass
    
    static var currentUser: User? = nil {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: CurrentUserDidChangeNotificationName), object: nil)
        }
    }
    
    //检查是否自动登录
    class func loginWithLocalUserInfo(success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        
        let UserToken = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) as? NSString
        let UserID = UserDefaults.standard.object(forKey: UserDefaultsUserIDKey) as? NSString
        var error: NSError? = nil
        if UserToken == nil || UserID==nil  {
            let userInfo = [
                NSLocalizedDescriptionKey: "本地usertoken或UserID不存在不存在",
                NSLocalizedFailureReasonErrorKey: ""
            ]
            failure?(NSError(
                domain: NetworkManager.defaultManager!.website,
                code: NetworkManager.defaultManager!.tokenFailCode,
                userInfo: userInfo))
        } else {
            
            // let er = AutoreleasingUnsafeMutablePointer<NSError?>(&error)
            guard let userID = UserID else {
                let alertView=SCLAlertView()
                alertView.addButton("确定", action: {})
                alertView.showError("提示", subTitle: "获取ID失败,无法从数据库读取数据")
                
                return
            }
            
            if let user = DataManager.defaultManager?.fetch("User", ID: userID, error: &error) as? User {
                success?(user)
            } else {
                var userInfo: [String: Any] = [
                    NSLocalizedDescriptionKey: "数据库用户信息不存在",
                    NSLocalizedFailureReasonErrorKey: "",
                    NSLocalizedRecoverySuggestionErrorKey: ""
                ]
                if error != nil {
                    userInfo[NSUnderlyingErrorKey] = error
                }
                failure?(NSError(
                    domain: NetworkManager.defaultManager!.website,
                    code: 404,
                    userInfo: userInfo as [AnyHashable: Any]))
            }
        }
    }
    //  /FamilyAccount/ResetPassword     APP忘记/修改密码
    class func ResetPassword(_ phone: String,code: String,password: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("ResetPassword",
                                                parameters: [
                                                    "phone": phone,
                                                    "code": code,
                                                    "password": password
            ],
                                                success: {
                                                    data in
                                                    //                                                print(data)
                                                    success!()
        },
                                                failure: failure)
    }
    //获取验证码
    class func SendPhoneCode(_ mobile: String,order: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("SendPhoneCode",
                                                parameters: [
                                                    "mobile": mobile,
                                                    "order": order,
                                                    "scope":"engineer"
            ],
                                                success: {
                                                    
                                                    data in
                                                    //                                                print(data)
                                                    success!()
                                                    
        },
                                                failure: failure)
    }
    
    //绑定银行卡时获取验证码
    class func SendPhoneCodeForBankCard(_ mobile: String,order: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("SendPhoneCode",
                                                 parameters: [
                                                    "mobile": mobile,
                                                    "order": order,
                                                    "scope":" "
            ],
                                                 success: {
                                                    data in
                                                    //                                                print(data)
                                                    success!()
        },
                                                 failure: failure)
    }
    
    
    //验证验证码
    class func AppChenkPhone(_ phone: String,code: String, success: ((String) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("AppChenkPhone",
                                                 parameters: ["phone": phone,"code": code],
                                                 success: {
                                                    data in
                                                    UserDefaults.standard.setValue(phone, forKey: "UserName")
                                                    
                                                    success!(data["msg"].stringValue)
        },
                                                 failure: failure)
    }
    // /FamilyAccount/AppRegister       APP端注册用户
    class func AppRegister(_ token:String, realname: String, cardid: String, password: String, inviteCode: String?, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        
        var params =  [
            "token": token,
            "realname": realname,
            "cardid": cardid,
            "password": password]
        if let invite = inviteCode {
            params["yqCode"] = invite
        }
        _ =  NetworkManager.defaultManager!.POST("AppRegister",parameters: params as NSDictionary,
                                                 success: {
                                                    data in
                                                    let defaults = UserDefaults.standard
                                                    defaults.set(data["msg"].stringValue, forKey: UserDefaultsUserTokenKey)
                                                    defaults.set(data["data"].stringValue, forKey: UserDefaultsUserIDKey)
                                                    defaults.setValue(password, forKey: "PassWord")
                                                    let user = User.cachedObjectWithID(data["data"].stringValue as NSString)//userId
                                                    user.usertoken = data["msg"].stringValue//usertoken
                                                    
                                                    
                                                    defaults.synchronize()
                                                    loginWithLocalUserInfo(success: success, failure: failure)
        },
                                                 failure: failure)
    }
    //登录
    class func loginWithPhone(_ phone: String, password: String, success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.clearCookies()
        _ =  NetworkManager.defaultManager!.POST("AppLogin",
                                                 parameters: [
                                                    "phone": phone,
                                                    "password": password
            ],
                                                 success: {
                                                    data in
                                                    let defaults = UserDefaults.standard
                                                    defaults.set(data["msg"].stringValue, forKey: UserDefaultsUserTokenKey)
                                                    defaults.set(data["data"].stringValue, forKey: UserDefaultsUserIDKey)
                                                    //保存账号密码
                                                    UserDefaults.standard.setValue(phone, forKey: "UserName")
                                                    UserDefaults.standard.setValue(password, forKey: "PassWord")
                                                    
                                                    let user = User.cachedObjectWithID(data["data"].stringValue as NSString)
                                                    user.id =  data["data"].stringValue //userId
                                                    user.usertoken = data["msg"].stringValue //usertoken
                                                    
                                                    defaults.synchronize()
                                                    loginWithLocalUserInfo(success: success, failure: failure)
                                                    
        },
                                                 failure: failure)
    }
    //获取当前用户信息
    class func GetCurrentUserInfo(_ success: ((User) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("GetCurrentUserInfo",
                                                 parameters: NSDictionary(),
                                                 success: {
                                                    data in
                                                    //                                                print(data)
                                                    let tmpData=data["data"]
                                                    let user = User.cachedObjectWithID(tmpData["userid"].stringValue as NSString)
                                                    user.city=tmpData["city"].stringValue
                                                    user.country=tmpData["country"].stringValue
                                                    var tmpUrl = tmpData["headimageurl"].stringValue
                                                    
                                                    if (tmpUrl.contains("http"))==false
                                                    {
                                                        if let _ = (NetworkManager.defaultManager?.website) {
                                                            
                                                            tmpUrl = (NetworkManager.defaultManager?.website)!+tmpUrl
                                                        }else{
                                                            tmpUrl = SERVICEADDRESS + tmpUrl
                                                        }
                                                        
                                                        user.headimageurl = tmpUrl
                                                    }else{
                                                        
                                                        user.headimageurl = tmpUrl
                                                    }
                                                    
                                                    
                                                    
                                                    //                                                if (tmpUrl != "")
                                                    //                                                {
                                                    //                                                    if (tmpUrl.containsString("http"))==false
                                                    //                                                    {
                                                    //                                                        tmpUrl=(NetworkManager.defaultManager?.website)!+tmpUrl
                                                    //                                                    }
                                                    //
                                                    //                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                                    //
                                                    //                                                        let headImageData = NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                    //
                                                    //                                                        dispatch_async(dispatch_get_main_queue(), {
                                                    //                                                             user.headimageurl = headImageData
                                                    //                                                        })
                                                    //
                                                    //                                                    })
                                                    //
                                                    //                                                }
                                                    
                                                    user.language=tmpData["language"].stringValue
                                                    user.mobile=tmpData["mobile"].stringValue
                                                    user.name=tmpData["nickname"].stringValue
                                                    user.openid=tmpData["openid"].stringValue
                                                    user.province=tmpData["province"].stringValue
                                                    user.scope=tmpData["scope"].stringValue
                                                    let tmpSex=tmpData["sex"].stringValue
                                                    user.sex=tmpSex
                                                    //                                                user.lat=(tmpData["lat"].stringValue) as NSNumber
                                                    //                                                user.lng=(tmpData["lat"].stringValue)as NSNumber
                                                    do{
                                                        // user.groupdetails = try? tmpData["GroupDetails"].rawData()
                                                        
                                                    }
                                                    success!(user)
        },
                                                 failure:
            failure
        )
    }
    
    
    //  /FamilyAccount/UpdateUserInfo    更新用户个人信息
    class func UpdateUserInfo(_ dataDic:NSDictionary, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        var constructingBlock:((AFMultipartFormData?) -> Void)?=nil
        if let tmpdata=dataDic["headImage"] {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let str = formatter.string(from: Date())
            let fileName = NSString(format: "%@", str)
            constructingBlock={
                data in
                var _ = data!.appendPart(withFileData: (tmpdata as! Data), name: (fileName as String), fileName: "headImage", mimeType: "image/png")
            }
        }
        _ =  NetworkManager.defaultManager!.request("UpdateUserInfo", GETParameters: nil, POSTParameters: dataDic, constructingBodyWithBlock: constructingBlock, success: {
            data in
            let tmpData=data["data"]
            let user = User.cachedObjectWithID(tmpData["userid"].stringValue as NSString)
            user.city=tmpData["city"].stringValue
            user.country=tmpData["country"].stringValue
            var tmpUrl = tmpData["headimageurl"].stringValue
            
            if (tmpUrl.contains("http"))==false
            {
                if let _ = (NetworkManager.defaultManager?.website) {
                    
                    tmpUrl = (NetworkManager.defaultManager?.website)!+tmpUrl
                }else{
                    tmpUrl = SERVICEADDRESS + tmpUrl
                }
                
                user.headimageurl = tmpUrl
            }else{
                
                user.headimageurl = tmpUrl
            }
            
            //            if (tmpUrl != "")
            //            {
            //                if (tmpUrl.containsString("http"))==false
            //                {
            //                    tmpUrl=(NetworkManager.defaultManager?.website)!+tmpUrl
            //                }
            //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //
            //                    let headImageData = NSData(contentsOfURL: NSURL(string: tmpUrl)!)
            //
            //                    dispatch_async(dispatch_get_main_queue(), {
            //                        user.headimageurl = headImageData
            //                    })
            //
            //                })
            //            }
            user.language=tmpData["language"].stringValue
            user.mobile=tmpData["mobile"].stringValue
            user.name=tmpData["nickname"].stringValue
            user.openid=tmpData["openid"].stringValue
            user.province=tmpData["province"].stringValue
            user.scope=tmpData["scope"].stringValue
            user.sex=tmpData["sex"].stringValue
            do{
                // user.groupdetails = try? tmpData["GroupDetails"].rawData()
            }
            User.currentUser=user
            success!()
        }, failure: failure)
        
        
    }
    //以下是未解析的借口
    //  /Command/SendMessage             APP发送消息
    class func SendMessage(_ recvuserid: String, message: String,messagetype: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("SendMessage",
                                                 parameters:[
                                                    "recvuserid":recvuserid,
                                                    "message":message,
                                                    "messagetype":messagetype
            ],
                                                 success: {
                                                    data in
                                                    //                                                print(data)
                                                    success!()
        },
                                                 failure: failure)
    }
    //  /Command/BingJgNotifyId          绑定极光通知ID
    class func BingJgNotifyId(_ notifyid: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("BingJgNotifyId",
                                                 parameters:[
                                                    "notifyid":notifyid
            ],
                                                 success: {
                                                    data in
                                                    //                                                print(data)
                                                    success!()
        },
                                                 failure: failure)
    }
    //  /Upload/Images                   上传图片接口
    class func UploadImages(_ frontImg:Data,backImg:Data, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        var constructingBlock:((AFMultipartFormData?) -> Void)?=nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let str = formatter.string(from: Date())
        let fileName = NSString(format: "%@", str)
        constructingBlock={
            data in
            data!.appendPart(withFileData: (frontImg), name: (fileName as String), fileName: "frontImg", mimeType: "image/png")
            data!.appendPart(withFileData: (backImg), name: (fileName as String)+"1", fileName: "backImg", mimeType: "image/png")
        }
        
        _ =  NetworkManager.defaultManager!.request("UploadImages", GETParameters: nil, POSTParameters: ["order":"cardvf"], constructingBodyWithBlock: constructingBlock, success: {
            data in
            //            print(data)
            success!()
        }, failure: failure)
        
    }
    //  /AppInterface/GetOrderList       分页获取可抢订单列表
    class func GetOrderList(_ paramDic: NSDictionary, success: ((NSMutableArray) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("GetOrderList",
                                                 parameters:paramDic,
                                                 success: {
                                                    data in
                                                    // print(data)
                                                    let tmpData = data["data"].array
                                                    //                                                print("*****************************")
                                                    // print(tmpData)
                                                    
                                                    guard let _ = tmpData else{
                                                        return
                                                    }
                                                    let orders=NSMutableArray()
                                                    for item in tmpData!{
                                                        let orderId=item["OrderId"].stringValue
                                                        let order = Order.cachedObjectWithID(orderId as NSString)
                                                        var tmpUser = item["user"]
                                                        order.city = item["city"].stringValue
                                                        order.describe = item["Describe"].stringValue
                                                        
                                                        let homeTime = item["hometime"]
                                                        if  homeTime["hometime"].stringValue == ""{
                                                            
                                                            order.appointmentTime = item["ServiceTime"].stringValue
                                                        }else{
                                                            order.appointmentTime = homeTime["hometime"].stringValue
                                                        }
                                                        
                                                        
                                                        order.province = item["Province"].stringValue
                                                        order.country = item["Country"].stringValue
                                                        order.id = item["OrderId"].stringValue//OrderId
                                                        var tmpUrl  = tmpUser["headimageurl"].stringValue
                                                        if (tmpUrl != "")//headimageurl
                                                        {
                                                            if (tmpUrl.contains("http"))==false
                                                            {
                                                                if (NetworkManager.defaultManager?.website) == nil{
                                                                    tmpUrl = SERVICEADDRESS + tmpUrl
                                                                }else{
                                                                    
                                                                    if NetworkManager.defaultManager != nil {
                                                                        
                                                                        tmpUrl=(NetworkManager.defaultManager?.website)!+tmpUrl
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                            order.headimageurl = tmpUrl //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                        }
                                                        else
                                                        {
                                                            order.headimageurl = ""
                                                        }
                                                        order.checkState = item["CRMCheck"].stringValue
                                                        order.productName = item["productinfo"]["ProductName"].stringValue
                                                        order.productModel = item["productinfo"]["ProductModel"].stringValue
                                                        order.createTime = item["CreateTime"].stringValue
                                                        order.address = item["Address"].stringValue
                                                        // order.describe = item["Describe"].stringValue
                                                        order.modifyTime = item["ModifyTime"].stringValue
                                                        order.distance = item["distance"].stringValue
                                                        let troubleHandle = item["ServiceItem"].stringValue
                                                        order.serviceItem = troubleHandle
                                                        order.lat=(item["lat"].stringValue as NSString).doubleValue as NSNumber?
                                                        order.lng=(item["lng"].stringValue as NSString).doubleValue as NSNumber?
                                                        orders.add(order)
                                                        
                                                    }
                                                    
                                                    success?(orders)
        },
                                                 failure:{(error) in
                                                    failure?(error)
                                                    
        })
    }
    //  /AppInterface/RobOrder           抢订单
    class func RobOrder(_ orderid: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =   NetworkManager.defaultManager!.POST("RobOrder",
                                                  parameters:["orderid":orderid],
                                                  success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                  failure: failure)
    }
    //  /AppInterface/FinshOrder     提交完成订单
    class func FinshOrder(_ dataDic:NSDictionary,imageDic:NSDictionary, palatte: NSDictionary, success: ((Int) -> Void)?, failure: ((NSError) -> Void)?) {
        var constructingBlock:((AFMultipartFormData?) -> Void)?=nil
        //    for(NSInteger i = 0; i < self.imageDataArray.count; i++)
        //            {
        //                NSData * imageData = [self.imageDataArray objectAtIndex: i];
        //                // 上传的参数名
        //                NSString * Name = [NSString stringWithFormat:@"%@%zi", Image_Name, i+1];
        //                // 上传filename
        //                NSString * fileName = [NSString stringWithFormat:@"%@.jpg", Name];
        //
        //                [formData appendPartWithFileData:imageData name:Name fileName:fileName mimeType:@"image/jpeg"];
        //        }
        //        let formatter = NSDateFormatter()
        //        formatter.dateFormat = "yyyyMMddHHmmss"
        //        let str = formatter.stringFromDate(NSDate())
        //        let fileName = NSString(format: "%@", str)
        
        //        if let tmpdata=dataDic["headImage"] {
        //            let formatter = NSDateFormatter()
        //            formatter.dateFormat = "yyyyMMddHHmmss"
        //            let str = formatter.stringFromDate(NSDate())
        //            let fileName = NSString(format: "%@", str)
        //            constructingBlock={
        //                data in
        //                var _ = data!.appendPartWithFileData((tmpdata as! NSData), name: (fileName as String), fileName: "headImage", mimeType: "image/png")
        //            }
        //        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let name = formatter.string(from: Date())
        let fileName = NSString(format: "%@", name)
        
        constructingBlock = { data in
            for index in 199...202 {
                if imageDic["pic"+"\(index)"] != nil{
                    
                    let imageData = imageDic["pic"+"\(index)"] as! Data
                    data?.appendPart(withFileData: imageData, name: (fileName as String)+"\(index)", fileName: "updataImage", mimeType: "image/png")
                    
                }
                
            }
            
            let palatteData = palatte["autograph"] as! Data
            data?.appendPart(withFileData: palatteData, name: "autograph", fileName: "updataImage", mimeType: "image/png")
        }
        
        
        _ =  NetworkManager.defaultManager!.request("FinshOrder", GETParameters: nil, POSTParameters: dataDic, constructingBodyWithBlock: constructingBlock, success: {
            data in
            
            let payState = data["state"].intValue
            success!(payState)
        }, failure: failure)
        
        
    }
    
    
    //  /AppInterface/GetOrderDetails    获取订单详细信息
    class func GetOrderDetails(_ orderid: String, success: (([AnyObject],[RNPAYDetailModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("GetOrderDetails",
                                                 parameters:[
                                                    "orderid":orderid
            ],
                                                 success: {
                                                    data in
                                                    //数组
                                                    //                                                print("--------------")
                                                    //                                                print(data)
                                                    //                                                print("--------------")
                                                    var  arr = [AnyObject]()
                                                    var item =   data["data"]
                                                    let orderId = item["OrderId"].stringValue
                                                    
                                                    // 支付信息
                                                    let json = item["payinfos"].array
                                                    var dataArray = [RNPAYDetailModel]()
                                                    for item in json!{
                                                        let model = RNPAYDetailModel()
                                                        
                                                        model.id = item["id"].stringValue
                                                        model.orderId = item["OrderId"].stringValue
                                                        model.PayTitle = item["PayTitle"].stringValue
                                                        model.UserId = item["UserId"].stringValue
                                                        model.Money = item["Money"].floatValue
                                                        model.OriMoney = item["OriMoney"].floatValue
                                                        model.PayState = item["PayState"].stringValue
                                                        model.Payway = item["Payway"].stringValue
                                                        
                                                        dataArray.append(model)
                                                    }
                                                    
                                                    
                                                    let ueritem = item["user"]
                                                    let orderDetail  = OrderDetail.cachedObjectWithID(orderId as NSString)
                                                    
                                                    orderDetail.orderId = orderId
                                                    orderDetail.crmID = item["CRMID"].stringValue // CRMID
                                                    orderDetail.hoyoID = item["DocumentNo"].stringValue // HoyoID
                                                    
                                                    var  tmpUrl = ueritem["headimageurl"].stringValue
                                                    if (tmpUrl != "")//headimageurl
                                                    {
                                                        if (tmpUrl.contains("http"))==false
                                                        {
                                                            if let _ = (NetworkManager.defaultManager?.website) {
                                                                
                                                                tmpUrl = (NetworkManager.defaultManager?.website)!+tmpUrl
                                                            }else{
                                                                tmpUrl = SERVICEADDRESS + tmpUrl
                                                            }
                                                        }
                                                        orderDetail.userImage = tmpUrl //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                    }
                                                    else
                                                    {
                                                        orderDetail.userImage = ""
                                                    }
                                                    var engnerImageItem = item["Engineer"]
                                                    var tmpEngnerImage = engnerImageItem["headimageurl"].stringValue
                                                    
                                                    if (tmpEngnerImage != "")//headimageurl
                                                    {
                                                        if (tmpEngnerImage.contains("http"))==false
                                                        {
                                                            tmpEngnerImage=(NetworkManager.defaultManager?.website)!+tmpUrl
                                                        }
                                                        orderDetail.enginerImage = tmpUrl //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                    }
                                                    else
                                                    {
                                                        orderDetail.enginerImage = ""
                                                    }
                                                    
                                                    var  tmpUrl2 = item["Images"]["ImageUrl"].stringValue
                                                    if (tmpUrl2 != "")//headimageurl
                                                    {
                                                        if (tmpUrl2.contains("http"))==false
                                                        {
                                                            if let _ = (NetworkManager.defaultManager?.website) {
                                                                
                                                                tmpUrl2 = (NetworkManager.defaultManager?.website)!+tmpUrl2
                                                            }else{
                                                                tmpUrl2 = SERVICEADDRESS + tmpUrl2
                                                            }
                                                        }
                                                        orderDetail.topImage = tmpUrl2 //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                    }
                                                    else{
                                                        orderDetail.topImage = ""
                                                    }
                                                    
                                                    let  tmpUrl3 = item["Images"].array
                                                    orderDetail.imageDetail = ""
                                                    for item in tmpUrl3!
                                                    {
                                                        var tmp = item["ImageUrl"].stringValue
                                                        
                                                        if  tmp !=  ""
                                                        {
                                                            if (tmp.contains("http"))==false
                                                            {
                                                                if let _ = (NetworkManager.defaultManager?.website) {
                                                                    
                                                                    tmp = (NetworkManager.defaultManager?.website)!+tmp
                                                                }else{
                                                                    tmp = SERVICEADDRESS + tmp
                                                                }
                                                            }
                                                            //orderDetail.imageDetail = tmp //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                            
                                                            
                                                        }
                                                        else {
                                                            tmp = ""
                                                            
                                                            
                                                        }
                                                        orderDetail.imageDetail = orderDetail.imageDetail! +  tmp  + "|"
                                                        
                                                    }
                                                    
                                                    orderDetail.mobile = item["UserPhone"].stringValue
                                                    
                                                    orderDetail.telephoneNumber = item["ClientMobile"].stringValue
                                                    
                                                    orderDetail.clientName = item["ClientName"].stringValue
                                                    
                                                    orderDetail.nickname = item["UserName"].stringValue
                                                    orderDetail.checkState = item["CRMCheck"].stringValue
                                                    orderDetail.distance = item["distance"].stringValue
                                                    orderDetail.address = item["Address"].stringValue
                                                    orderDetail.addressDetail = item["Address"].stringValue
                                                    
                                                    let homeTime = item["hometime"]
                                                    // orderDetail.visitTime = homeTime["hometime"].stringValue
                                                    if  homeTime["hometime"].stringValue == ""{
                                                        
                                                        orderDetail.visitTime = item["ServiceTime"].stringValue
                                                    }else{
                                                        orderDetail.visitTime = homeTime["hometime"].stringValue
                                                    }
                                                    
                                                    //  orderDetail.visitTime  =  item["ServiceTime"].stringValue
                                                    
                                                    orderDetail.troubleDescripe = item["Describe"].stringValue
                                                    orderDetail.troubleHandleType = NetworkManager.defaultManager?.getTroubleHandle(item["ServiceItem"].stringValue).firstObject as? String
                                                    orderDetail.country = item["Country"].stringValue
                                                    orderDetail.province = item["Province"].stringValue
                                                    orderDetail.city = item["City"].stringValue
                                                    orderDetail.lat=item["lat"].stringValue
                                                    orderDetail.lng=item["lng"].stringValue
                                                    
                                                    orderDetail.productName =  item["productinfo"]["ProductName"].stringValue
                                                    orderDetail.productModel = item["productinfo"]["ProductModel"].stringValue
                                                    orderDetail.productBrand = item["productinfo"]["CompanyName"].stringValue
                                                    orderDetail.areaCode = item["areacode"].stringValue
                                                    
                                                    //目的地址
                                                    orderDetail.aimAdress = "\(item["DesProvince"].stringValue)" + "\(item["DesCity"].stringValue)" + "\(item["DesCountry"].stringValue)" + "\(item["DesAddress"].stringValue)"
                                                    
                                                    // 快递信息
                                                    let inventoryInfo = item["InventoryInfo"]
                                                    let tradeStatus = inventoryInfo["tradeStatuss"].array
                                                    
                                                    if let frt = tradeStatus?.first{
                                                        orderDetail.expressCode = frt["trackNumber"].stringValue
                                                    }else{
                                                        orderDetail.expressCode = ""
                                                    }

                                                    orderDetail.deviceType = item["DeviceType"].stringValue
                                                    
                                                    arr.append(orderDetail)
                                                    
                                                    // 订单完成信息
                                                    if item["finshDetails"]["orderid"].stringValue != ""{
                                                        
                                                        
                                                        // 完成详情
                                                        let finishDetail = FinshDetail()
                                                        finishDetail.photos = [] // 初始化图片数组
                                                        var tmpFinish = item["finshDetails"]
                                                        var tmpEva = item["evaluate"]
                                                        finishDetail.arrivetime = tmpFinish["arrivetime"].stringValue
                                                        finishDetail.orderId = tmpFinish["orderid"].stringValue
                                                        finishDetail.usetime = tmpFinish["usetime"].stringValue
                                                        finishDetail.money = tmpFinish["money"].stringValue
                                                        finishDetail.troubleDetail = tmpFinish["Fault"].stringValue // 故障原因
                                                        finishDetail.reason = tmpFinish["Solution"].stringValue // 解决办法
                                                        finishDetail.payWay = tmpFinish["PayWay"].stringValue
                                                        let demoString =  tmpEva["Remark"].stringValue
                                                        finishDetail.remark = demoString
                                                        
                                                        let images = tmpFinish["Images"].array
                                                        if let imgs = images{
                                                            
                                                            for item in imgs {
                                                                var tmp = item["ImageUrl"].stringValue
                                                                if  tmp !=  ""
                                                                {
                                                                    if (tmp.contains("http"))==false
                                                                    {
                                                                        if let _ = (NetworkManager.defaultManager?.website) {
                                                                            
                                                                            tmp = (NetworkManager.defaultManager?.website)!+tmp
                                                                        }else{
                                                                            tmp = SERVICEADDRESS + tmp
                                                                        }
                                                                    }
                                                                    
                                                                    finishDetail.photos?.append(tmp)
                                                                    
                                                                }
                                                                
                                                            }
                                                        }
                                                        
                                                        arr.append(finishDetail)
                                                        
                                                        
                                                    }
                                                    
                                                    if item["settlementinfo"]["OrderId"].stringValue != ""
                                                    {
                                                        var tmpsettlementinfo = item["settlementinfo"]
                                                        let settlementinfoDetail = Settlementinfo()
                                                        
                                                        settlementinfoDetail.debitMoney = tmpsettlementinfo["DebitMoney"].stringValue
                                                        settlementinfoDetail.higherMoney = tmpsettlementinfo["HigherMoney"].stringValue
                                                        settlementinfoDetail.money = tmpsettlementinfo["Money"].stringValue
                                                        settlementinfoDetail.settleTime = tmpsettlementinfo["CreateTime"].stringValue
                                                        
                                                        arr.append(settlementinfoDetail)
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                    success!( arr,dataArray)
        },
                                                 failure: failure)
    }
    
    
    //GetPost/Command/NewVersion获取版本更新
    class func NewVersion(_ paramDic: NSDictionary, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("NewVersion",
                                                 parameters:paramDic,
                                                 success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                 failure: failure)
    }
    //GetPost/AppInterface/RefreshIndex   APP刷新首页获取数据
    class func RefreshIndex(_ success: ((User, [String], [String], [RNServiceAreasModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("RefreshIndex",
                                                 parameters:NSDictionary(),
                                                 success: {
                                                    data in
                                                    
                                                    // print(data)
                                                    let tmpData=data["data"]
                                                    
                                                    var headBanners = [String]()
                                                    var footBanners = [String]()
                                                    let banners = tmpData["appsettings"].array
                                                    
                                                    // print(banners)
                                                    for item in banners! {
                                                        
                                                        let kind = item["SettingKind"].stringValue
                                                        if kind == "100000" {
                                                            headBanners.append(item["SettingValue"].stringValue)
                                                        }else if kind == "200000" {
                                                            footBanners.append(item["SettingValue"].stringValue)
                                                        }
                                                    }
                                                    
                                                    let tmpUser=tmpData["user"]
                                                    let user = User.cachedObjectWithID(tmpUser["userid"].stringValue as NSString)
                                                    user.city=tmpUser["city"].stringValue
                                                    user.country=tmpUser["country"].stringValue
                                                    var tmpUrl = tmpUser["headimageurl"].stringValue
                                                    
                                                    if (tmpUrl.contains("http"))==false
                                                    {
                                                        
                                                        if let _ = (NetworkManager.defaultManager?.website){
                                                            
                                                            tmpUrl=(NetworkManager.defaultManager?.website)!+tmpUrl
                                                            
                                                            user.headimageurl = tmpUrl
                                                        }else{
                                                            user.headimageurl = SERVICEADDRESS + tmpUrl
                                                        }
                                                        
                                                    }else{
                                                        
                                                        user.headimageurl = tmpUrl
                                                    }
                                                    
                                                    //
                                                    //                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                                    //
                                                    //                                                        let headImageData = NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                    //
                                                    //                                                        dispatch_async(dispatch_get_main_queue(), {
                                                    //                                                            user.headimageurl = headImageData
                                                    //                                                        })
                                                    //
                                                    //                                                    })
                                                    //
                                                    //                                                }
                                                    user.language=tmpUser["language"].stringValue
                                                    user.mobile=tmpUser["mobile"].stringValue
                                                    user.name=tmpUser["nickname"].stringValue
                                                    user.openid=tmpUser["openid"].stringValue
                                                    user.province=tmpUser["province"].stringValue
                                                    user.scope=tmpUser["scope"].stringValue
                                                    user.sex=tmpUser["sex"].stringValue
                                                    //                                  String((data["score"]["Score"].intValue)/(data["score"]["Number"].intValue))
                                                    //                                                print(tmpData["score"]["Score"].stringValue)
                                                    //                                                user.score=tmpUser["score"].stringValue
                                                    // print(ceil((tmpData["score"]["Score"].doubleValue)/(tmpData["score"]["Number"].doubleValue)))
                                                    
                                                    // 服务区域获取
                                                    let GroupDetails = tmpUser["GroupInfoDetails"]
                                                    let ServiceAreas = GroupDetails["ServiceAreas"].array
                                                    var serviceAreaArray = [RNServiceAreasModel]()
                                                    if ServiceAreas != nil {
                                                        for item in ServiceAreas!{
                                                            let model = RNServiceAreasModel()
                                                            model.province = item["Province"].stringValue
                                                            model.city = item["City"].stringValue
                                                            model.country = item["Country"].stringValue
                                                            
                                                            serviceAreaArray.append(model)
                                                        }
                                                    }
                                                    
                                                    if tmpData["score"]["Number"].intValue > 0 {
                                                        user.score = String(Int(ceil((tmpData["score"]["Score"].doubleValue)/(tmpData["score"]["Number"].doubleValue))))
                                                    } else {
                                                        user.score = ""
                                                    }
                                                    user.bdimgs=tmpUser["bdimgs"].stringValue
                                                    user.bannerimgs=tmpUser["bannerimgs"].stringValue
                                                    
                                                    do{
                                                        user.realname = try? tmpData["realname"].rawData()
                                                        user.orderabout = try? tmpData["orderabout"].rawData()
                                                        // user.groupdetails = try? tmpUser["GroupDetails"].rawData()
                                                    }
                                                    success!(user, headBanners, footBanners, serviceAreaArray)
        },
                                                 failure:{(error) in
                                                    failure!(error)
        })
    }
    
    //GetPost/AppInterface/SubmitTime提交上门时间
    class func SubmitTime(_ paramDic: NSDictionary, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("SubmitTime",
                                                 parameters:paramDic,
                                                 success: {
                                                    data in
                                                    
                                                    // print(data)
                                                    success!()
        },
                                                 failure: failure)
    }
    //GetPost/AppInterface/GetHomeTimeList获取历史提交的上门时间
    class func GetHomeTimeList(_ orderid: String, success: (([HistoryList]) -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("GetHomeTimeList",
                                                parameters:[
                                                    "orderid":orderid
            ],
                                                success: {
                                                    data in
                                                    //print(data)
                                                    let tmpdata=data["data"].array
                                                    var historyArr=[HistoryList]()
                                                    for item in tmpdata!
                                                    {
                                                        
                                                        // let orderId=item["orderid"].stringValue
                                                        // print(orderId)
                                                        let history = HistoryList()
                                                        history.arriveTime=item["hometime"].stringValue
                                                        history.id=item["orderid"].stringValue
                                                        history.remark=item["remark"].stringValue
                                                        // print(history.remark)
                                                        historyArr.append(history)
                                                    }
                                                    // print(historyArr)
                                                    success!(historyArr)
        },
                                                failure: failure)
    }
    //GetPost/AppInterface/PartnerCommand组(合伙人)成员操作
    class func PartnerCommand(_ params:NSDictionary, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("PartnerCommand",
                                                 parameters:params,
                                                 success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                 failure: failure)
    }
    //GetPost/AppInterface/UpgradeAuthority升级权限
    class func UpgradeAuthority(_ paramDic: NSDictionary, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("UpgradeAuthority",
                                                 parameters:paramDic,
                                                 success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                 failure: failure)
    }
    
    //GetPost/AppInterface/GetNowAuthorityDetail获取当前权限的信息或者审核进度，获取团队成员信息---弃用
    class func GetNowAuthorityDetail
        (_ success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("GetNowAuthorityDetail",
                                                parameters:nil,
                                                success: {
                                                    data in
                                                    // print(data)
                                                    success!()
        },
                                                failure: failure)
    }
    
    //我的团队
    class func GetNowAuthorityDetailInfo
        (_ success: (([TeamMembers],[MyTeamModel],String) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("GetNowAuthorityDetail",
                                                 parameters:nil,
                                                 success: {
                                                    data in
                                                    print(data)
                                                    var areaStrArr:String = ""
                                                    let tmpData = data["data"]
                                                    let model = MyTeamModel.cachedObjectWithID(tmpData["id"].stringValue as NSString)
                                                    var teamArr = Array<MyTeamModel>()
                                                    var memberArr = Array<TeamMembers>()
                                                    model.headimageurl = (tmpData["user"]["headimageurl"]).stringValue
                                                    model.groupName =  (tmpData["user"]["GroupDetails"]["GroupName"]).stringValue
                                                    model.userself = tmpData["userself"]["userid"].stringValue
                                                    model.userselfNickname = tmpData["userself"]["nickname"].stringValue
                                                    
                                                    let memArr = tmpData["members"].array
                                                    for item in memArr! {
                                                        if model.userself == item["user"]["userid"].stringValue {
                                                            model.userselfCreateTime = item["JoinTime"].stringValue
                                                        }
                                                    }
                                                    
                                                    
                                                    if let time = model.userselfCreateTime {
                                                        if time != "" {
                                                            let date = DateTool.dateFromServiceTimeStamp(time)
                                                            model.userselfCreateTime = DateTool.stringFromDate(date!, dateFormat: "YYYY-MM-dd")
                                                        }
                                                    }
                                                    model.userselfMemberState = tmpData["userself"]["GroupDetails"]["MemberState"].stringValue
                                                    if let modelState = model.userselfMemberState{
                                                        switch(modelState)
                                                        {
                                                        case "70001":
                                                            model.userselfMemberState = "审核成功"
                                                            break
                                                        case "70000":
                                                            model.userselfMemberState = "审核中"
                                                        case "70002":
                                                            model.userselfMemberState = "审核失败"
                                                        case "70003":
                                                            model.userselfMemberState = "被封号了"
                                                        default:
                                                            break
                                                        }
                                                    }
                                                    
                                                    model.groupNumber = (tmpData["user"]["GroupDetails"]["GroupNumber"]).stringValue
                                                    let arr = tmpData["user"]["GroupDetails"]["ServiceAreas"]
                                                    let areaCount = arr.count
                                                    
                                                    for  num in 0..<areaCount {
                                                        
                                                        model.province = (tmpData["user"]["GroupDetails"]["ServiceAreas"][num]["Province"]).stringValue
                                                        model.city =  (tmpData["user"]["GroupDetails"]["ServiceAreas"][num]["City"]).stringValue
                                                        model.country = (tmpData["user"]["GroupDetails"]["ServiceAreas"][num]["Country"]).stringValue
                                                        let areaStr = model.province! + " " + model.city! + " " + model.country!
                                                        areaStrArr = areaStrArr + areaStr + "\n"
                                                    }
                                                    model.nickname = (tmpData["user"]["nickname"]).stringValue
                                                    model.createTime = (tmpData["groupinfo"]["CreateTime"]).stringValue
                                                    model.suplevel1 = (tmpData["groupinfo"]["suplevel1"]).stringValue
                                                    model.suplevel2 = (tmpData["groupinfo"]["suplevel2"]).stringValue
                                                    model.suplevel3 = (tmpData["groupinfo"]["suplevel3"]).stringValue
                                                    //scopevalue 代替保证金
                                                    model.scopevalue = (tmpData["groupinfo"]["deposit"]).stringValue
                                                    //scopename 代替合伙人分类
                                                    model.scopename = (tmpData["groupinfo"]["PartnerType"]).stringValue
                                                    if let time = model.createTime {
                                                        if time != "" {
                                                            let date = DateTool.dateFromServiceTimeStamp(time)
                                                            model.createTime = DateTool.stringFromDate(date!, dateFormat: "YYYY-MM-dd")
                                                        }
                                                    }
                                                    model.memberState = (tmpData["user"]["GroupDetails"]["MemberState"]).stringValue
                                                    model.groupScopeName = tmpData["attibutes"][1]["scopename"].stringValue
                                                    model.groupScoupValue = tmpData["attibutes"][1]["scopevalue"].stringValue
                                                    //                                                model.scopename = tmpData["attibutes"][0]["scopename"].stringValue
                                                    //                                                model.scopevalue = tmpData["attibutes"][0]["scopevalue"].stringValue
                                                    if let modelState = model.memberState{
                                                        switch(modelState)
                                                        {
                                                        case "70001":
                                                            model.memberState = "审核成功"
                                                            break
                                                        case "70000":
                                                            model.memberState = "审核中"
                                                        case  "70002":
                                                            model.memberState = "审核失败"
                                                        case "70003":
                                                            model.memberState = "被封号了"
                                                        default:
                                                            break
                                                        }
                                                    }
                                                    //团队成员信息
                                                    let memberData = tmpData["members"]
                                                    let count = memberData.count
                                                    for  num in 0..<count  {
                                                        let memModel = TeamMembers()
                                                        memModel.headimageurl = memberData[num]["user"]["headimageurl"].stringValue
                                                        memModel.mobile = memberData[num]["user"]["mobile"].stringValue
                                                        memModel.nickname = memberData[num]["user"]["nickname"].stringValue
                                                        memModel.province = memberData[num]["user"]["province"].stringValue
                                                        memModel.city = memberData[num]["user"]["city"].stringValue
                                                        memModel.MemberState  = memberData[num]["user"]["GroupDetails"]["MemberState"].stringValue
                                                        memModel.GroupNumber = memberData[num]["GroupNumber"].stringValue
                                                        memModel.Scope = memberData[num]["Scope"].stringValue
                                                        memModel.userid = memberData[num]["user"]["userid"].stringValue
                                                        if let stateMem = memModel.Scope {
                                                            switch (stateMem)
                                                            {
                                                            case "n-partner":
                                                                memModel.Scope = "一般合伙人"
                                                                break
                                                            case "l-engineer":
                                                                memModel.Scope = "联席工程师"
                                                                break
                                                            case "partner":
                                                                memModel.Scope = "首席合伙人"
                                                                break
                                                            default:
                                                                break
                                                            }
                                                        }
                                                        memberArr.append(memModel)
                                                    }
                                                    teamArr.append(model)
                                                    success!(memberArr,teamArr,areaStrArr)
        },
                                                 failure:{(error) in
                                                    failure!(error)
        })
        
    }
    
    
    //GetPost/AppInterface/GetMyScoreDetails获取个人的所有评价
    class func GetMyScoreDetails (_ success: ((Evaluation,[ScoreDetail]) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager!.POST("GetMyScoreDetails",
                                                 parameters:nil,
                                                 success: {
                                                    data in
                                                    // print(data)
                                                    let evaluation = Evaluation()
                                                    var tmpData = data["data"]
                                                    var tempEvaluation = tmpData["score"]
                                                    evaluation.userid =   tempEvaluation["Userid"].stringValue
                                                    evaluation.score = tempEvaluation["Score"].stringValue == "" ? "0" : tempEvaluation["Score"].stringValue
                                                    evaluation.number = tempEvaluation["Number"].stringValue == "" ? "0" : tempEvaluation["Number"].stringValue
                                                    
                                                    let tmpScoreLists = tmpData["scorelist"].array
                                                    var scoreLists = [ScoreDetail]()
                                                    
                                                    for tmpScoreList in tmpScoreLists!
                                                    {
                                                        let scoreList = ScoreDetail.cachedObjectWithID(tmpScoreList["Id"].stringValue as NSString)
                                                        scoreList.orderId =  tmpScoreList["Orderid"].stringValue
                                                        scoreList.userid = tmpScoreList["Userid"].stringValue
                                                        scoreList.score = tmpScoreList["Score"].stringValue
                                                        scoreList.remark = tmpScoreList["Remark"].stringValue
                                                        scoreList.createTime = tmpScoreList["CreateTime"].stringValue
                                                        // =tmpData["headimageurl"].stringValue
                                                        var tmpUrl     = tmpScoreList["user"]["headimageurl"].stringValue
                                                        if (tmpUrl != "")
                                                        {
                                                            if (tmpUrl.contains("http"))==false
                                                            {
                                                                
                                                                if let _ = (NetworkManager.defaultManager?.website) {
                                                                    
                                                                    tmpUrl = (NetworkManager.defaultManager?.website)!+tmpUrl
                                                                }else{
                                                                    tmpUrl = SERVICEADDRESS + tmpUrl
                                                                }
                                                            }
                                                            scoreList.headimageurl = tmpUrl //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                        }
                                                        
                                                        //                                                    scoreList.headimageurl = tmpScoreList["user"]["headimageurl"].stringValue
                                                        scoreLists.append(scoreList)
                                                        
                                                    }
                                                    
                                                    success!(evaluation,scoreLists)
        },
                                                 failure: failure)
    }
    //GetPost/Command/GetOwenBindBlankCard获取所有我的绑定银行卡列表
    class func GetOwenBindBlankCard (_ success: (([BankModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("GetOwenBindBlankCard",
                                                parameters:nil,
                                                success: {
                                                    data in
                                                    
                                                    
                                                    
                                                    let tmpData = data["data"].array
                                                    
                                                    var tmpArr = [BankModel]()
                                                    
                                                    for item in tmpData!{
                                                        
                                                        let bankModel = BankModel.cachedObjectWithID(item["id"].stringValue as NSString)
                                                        bankModel.bankName = item["OpeningBank"].stringValue //银行名称
                                                        bankModel.cardId = item["CardId"].stringValue
                                                        bankModel.bindTime = item["BindTime"].stringValue
                                                        bankModel.userName = item["CardUserName"].stringValue
                                                        bankModel.cardPhone = item["ReservedPhoneNum"].stringValue
                                                        bankModel.bankBranch = item["BranchBank"].stringValue
                                                        bankModel.bankId = item["id"].stringValue
                                                        tmpArr.append(bankModel)
                                                    }
                                                    
                                                    
                                                    
                                                    success!(tmpArr)
        },
                                                failure: failure)
    }
    
    //GetPost/Command/BindNewBlankCard绑定银行卡
    class func BindNewBlankCard(_ paramDic: NSDictionary, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("BindNewBlankCard",
                                                parameters:paramDic,
                                                success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                failure: failure)
    }
    
    
    //GetPost/AppInterface/GetOwenMoney获取我的账户余额
    
    class func GetOwenMoney (_ success: ((MyAccount) -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("GetOwenMoney",
                                                parameters:nil,
                                                success: {
                                                    data in
                                                    
                                                    // print("88888888:\(data)")
                                                    
                                                    let tmpData = data["data"]
                                                    print(tmpData)
                                                    let myAccount = MyAccount.cachedObjectWithID(tmpData["id"].stringValue as NSString)
                                                    myAccount.balance = tmpData["money"].stringValue // 可提现
                                                    myAccount.income = tmpData["IncomeMoney"].stringValue // 总收入
                                                    myAccount.totalAssets = tmpData["ExpenditureMoney"].stringValue // 总支出
                                                    success!(myAccount)
        },
                                                failure:{ (error) in
                                                    failure!(error)
        })
        
    }
    
    
    //工程师提现提交信息/AppInterface/WithDraw
    class func submitInfoToGetMoney(_ paramDic: NSDictionary, success: (() -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("WithDraw",
                                                 parameters:paramDic,
                                                 success: { data in
                                                    
                                                    success!()
        },
                                                 failure:{ (error) in
                                                    failure!(error)
        })
        
    }
    
    
    //GetPost/AppInterface/GetOwenMoneyDetails分页获取我的账户明细
    class func GetOwenMoneyDetails (_ index : Int,pagesize : Int,moneyType: Int,success: (([AccountDetailModel]) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("GetOwenMoneyDetails", parameters: ["index":index ,"pagesize" :pagesize, "moneytype": moneyType],
                                                 success: { (data) in
                                                    // print(data)
                                                    let tmpData = data["data"].array
                                                    var tmpArr = Array<AccountDetailModel>()
                                                   // print(tmpData)
                                                    for item in tmpData! {
                                                        let model = AccountDetailModel.cachedObjectWithID(item["ID"].stringValue as NSString)
                                                       // let model = AccountDetailModel()
                                                        model.payId = item["OrderNo"].stringValue
                                                        //  print(model.payId)
                                                        model.money = item["Money"].stringValue
                                                        model.createTime = item["CreateTime"].stringValue
                                                        model.way = item["MoneyType"].stringValue
                                                        if  let time = model.createTime{
                                                            if time != "" {
                                                                let date = DateTool.dateFromServiceTimeStamp(time)
                                                                model.createTime = DateTool.stringFromDate(date!, dateFormat: "yyyy-MM-dd HH:mm EEEE")
                                                            }
                                                        }
                                                        
                                                        tmpArr.append(model)
                                                    }
                                                    success!(tmpArr)
        }, failure:{ (error) in
            failure!(error)
        })
    }
    
    
    //删除团队相关的一切（用于解散团队/团队拒绝后重新申请前的操作）
    class func DeleteTeamAll(_ groupNumber: Int, success:(() -> Void)?,failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("DeleteTeamAll", parameters: ["groupNumber": groupNumber], success: { (data) in
            
            // print("解散团队成功" + "\(data)")
            success!()
            
        }, failure: { (error) in
            failure!(error)
        })
        
    }
    ///用户退出当前团队
    class func RemoveTeamMember(_ groupNumber: Int,success:(() -> Void)?,failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("RemoveGroupMember", parameters: ["GroupNumber":groupNumber], success: { (data) in
            //  print("退出当前团队成功")
            success!()
        }, failure: { (error) in
            //  print(error)
            failure!(error)
        })
    }
    
    //审核当前团队成员
    class func AuditGroupMember(_ params: NSDictionary,success:(() -> Void)?,failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("AuditGroupMember", parameters: params, success: { (data) in
            // print("审核成功")
            success!()
        }, failure: { (error) in
            //                print(error)
            failure!(error)
        })
    }
    
    //移除团队成员
    class func RemoveCurrentTeamMember(_ groupNumber: Int,useid:Int,success:(() -> Void)?,failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("RemoveGroupMember", parameters: ["GroupNumber":groupNumber,"userid": useid], success: { (data) in
            //            print("移除成员成功")
            success!()
        }, failure: { (error) in
            //                print(error)
            failure!(error)
        })
    }
    
    //获取我的团队成员
    class func GetMyGroupMembers(_ pagesize: Int,index:Int,success:(([TeamMembers]) -> Void)?,failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("GetMyGroupMembers", parameters: ["pagesize":pagesize,"index": index], success: { (data) in
            //            print("获取团队成员成功")
            //            print(data)
            let tmpData = data["data"].array
            var memArr = Array<TeamMembers>()
            for item in tmpData!{
                let member = TeamMembers()
                
                member.headimageurl = item["User"]["headimageurl"].stringValue
                member.mobile = item["User"]["mobile"].stringValue
                member.nickname = item["User"]["nickname"].stringValue
                member.province = item["User"]["province"].stringValue
                member.city =  item["User"]["city"].stringValue
                //                member.MemberState = item["User"]["GroupDetails"]["MemberState"].stringValue
                member.Scope = item["Member"]["Scope"].stringValue
                member.userid = item["Member"]["UserId"].stringValue
                //记录当前成员是否已通过审核
                member.MemberState = item["Member"]["State"].stringValue
                member.GroupNumber = item["Member"]["GroupNumber"].stringValue
                if let stateMem = member.Scope {
                    switch (stateMem)
                    {
                    case "n-partner":
                        member.Scope = "一般合伙人"
                        break
                    case "l-engineer":
                        member.Scope = "联席工程师"
                        break
                    case "partner":
                        member.Scope = "首席合伙人"
                        break
                    default:
                        break
                    }
                }
                memArr.append(member)
            }
            
            success!(memArr)
        }, failure: { (error) in
            //                print(error)
            failure!(error)
        })
    }
    
    //
    //
    //
    //
    //
    //
    //
    //
    //    Get
    //    Post
    //    /Command/GetPriceTable获取浩泽产品信息
    
    class func GetPriceTable (_ index : Int, pagesize : Int, searchString: String?, success: (([ProductInfo]) -> Void)?, failure: ((NSError) -> Void)?) {
        
        _ =  NetworkManager.defaultManager?.POST("GetPriceTable", parameters: ["Pageindex":index ,"Pagesize" :pagesize, "search": searchString ?? ""],
                                                 success: { (data) in
                                                    var productinfos = [ProductInfo]()
                                                    let tmpData = data["data"].array
                                                    for item in tmpData!{
                                                        
                                                        let productinfo =  ProductInfo.cachedObjectWithID(item["ID"].stringValue as NSString);
                                                        productinfo.id = item["ID"].stringValue
                                                        
                                                        var tmpUrl  = item["PicPath"].stringValue
                                                        if (tmpUrl != "")//headimageurl
                                                        {
                                                            
                                                            
                                                            
                                                            if (tmpUrl.contains("http"))==false
                                                            {
                                                                
                                                                if let _ = (NetworkManager.defaultManager?.website) {
                                                                    
                                                                    tmpUrl = (NetworkManager.defaultManager?.website)!+tmpUrl
                                                                }else{
                                                                    tmpUrl = SERVICEADDRESS + tmpUrl
                                                                }
                                                            }
                                                            
                                                            productinfo.image = tmpUrl //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                                                        }
                                                        else
                                                        {
                                                            productinfo.image = ""
                                                        }
                                                        
                                                        productinfo.price = item["PJPrice"].stringValue
                                                        productinfo.name = item["Name"].stringValue
                                                        
                                                        productinfo.productsID = item["ProductsID"].stringValue
                                                        productinfo.pjCode = item["PJCode"].stringValue
                                                        productinfo.chCount = item["GHCount"].numberValue
                                                        productinfo.hsCount = item["HSCount"].numberValue
                                                        productinfo.pjNO = item["PjNo"].stringValue
                                                        productinfo.dw = item["DW"].stringValue
                                                        productinfo.k3PJ = item["K3Pj"].stringValue
                                                        //  productinfo.numbers = item["ProductsID"].stringValue
                                                        //  productinfo.productType = item["ProductsID"].stringValue
                                                        // productinfo.company = item["ProductsID"].stringValue
                                                        
                                                        productinfos.append(productinfo)
                                                    }
                                                    //                                                print(data)
                                                    success!(productinfos)
        }, failure: failure)
    }
    
    //GetPost/AppInterface/GetCurrentRealNameInfo获取当前的实名认证信息
    
    class func GetCurrentRealNameInfo(_ success:((String) -> Void)?,failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("GetCurrentRealNameInfo", parameters: nil, success: { (data) in
            //            print(data["data"]["checkstate"].stringValue)
            success!(data["data"]["checkstate"].stringValue)
        }, failure: { (error) in
            //                print(error)
            failure!(error)
        })
    }
    //  /AppInterface/UploadRealnameAuthinfo   上传实名认证信息
    class func UploadRealnameAuthinfo(_ name:String,cardid:String,frontImg:Data,backImg:Data, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        
        var constructingBlock:((AFMultipartFormData?) -> Void)?=nil
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let str = formatter.string(from: Date())
        let fileName = NSString(format: "%@", str)
        constructingBlock={
            data in
            data!.appendPart(withFileData: (frontImg), name: "cardfront", fileName: (fileName as String), mimeType: "image/png")
            data!.appendPart(withFileData: (backImg), name: "cardbehind", fileName: (fileName as String)+"1", mimeType: "image/png")
            
        }
        _ =  NetworkManager.defaultManager!.request("UploadRealnameAuthinfo", GETParameters: nil, POSTParameters: ["name":name,"cardid":cardid], constructingBodyWithBlock: constructingBlock, success: {
            data in
            //            print(data["data"]["ServiceId"].stringValue)
            success!()
        }, failure: failure)
        
    }
    ///AppInterface/CheckServiceTrain检查并获取服务直通车ID
    
    
    class func CheckServiceTrain(_ serviceid:String,success:((_ ServiceId:String,_ MachineKind:String,_ MachineBrand:String,_ UserPhone:String) -> Void)?,failure: ((NSError) -> Void)?) {
        
        _ =  NetworkManager.defaultManager?.POST("CheckServiceTrain", parameters: ["serviceid":serviceid], success: { (data) in
            //            print(data)
            success!(data["data"]["ServiceId"].stringValue,data["data"]["MachineKind"].stringValue,data["data"]["MachineBrand"].stringValue,data["data"]["UserPhone"].stringValue)
        }, failure: { (error) in
            //                print(error)
            failure!(error)
        })
    }
    ///AppInterface/UpdateServiceTrainMachine更新服务直通车绑定的信息
    
    class func UpdateServiceTrainMachine(_ serviceid:String,MachineKind:String,MachineBrand:String,UserPhone:String,success:(() -> Void)?,failure: ((NSError) -> Void)?) {
        _ =  NetworkManager.defaultManager?.POST("UpdateServiceTrainMachine", parameters: ["serviceid":serviceid,"MachineKind":MachineKind,"MachineBrand":MachineBrand,"UserPhone":UserPhone], success: { (data) in
            //            print(data)
            success!()
        }, failure: { (error) in
            //                print(error)
            failure!(error)
        })
    }
    
    
    // /AppInterface/GetPreRankDetails 绩效排行榜
    class func GetPerRankDetails(_ type: String, pageindex: String,pageSize: String = "10", success: (([RankDetailModel]) -> Void)?, failure: ((NSError) -> Void)?){
        _ =   NetworkManager.defaultManager!.POST("GetPreRankDetails", parameters: ["model":type, "pageindex":pageindex, "pagesize":pageSize], success: { (data) in
            //            print("bbbbbbbbbbbbank:\(data)")
            
            let tmpData = data["data"].array
            var tmpArr = [RankDetailModel]()
            
            if tmpData == nil{
                
            }else{
                
                for item in tmpData!{
                    
                    let rankModel =  RankDetailModel() //RankDetailModel.cachedObjectWithID(item["id"].stringValue)
                    rankModel.userId = item["UserId"].stringValue // 用户id
                    rankModel.username = item["Name"].stringValue // 用户名
                    rankModel.headImageUrl = item["HeadImage"].stringValue // 头像
                    rankModel.rank = item["rank"].stringValue // 排名
                    rankModel.score = item["FinshCount"].stringValue // 分数
                    rankModel.phone = item["Phone"].stringValue // 手机号
                    
                    let tempDic = item["Score"]
                    rankModel.grade = tempDic["Score"].stringValue // 总评分
                    rankModel.comments = tempDic["Number"].stringValue // 总评论
                    
                    tmpArr.append(rankModel)
                }
                
            }
            
            success!(tmpArr)
            
        }) { (error) in
            failure!(error)
        }
        
    }
    
    //通过服务直通车查看服务记录
    class func GetServiceRecordByServiceTrain(_ servicecode:String,pageindex:Int,pagesize:Int, success: (([Order]) -> Void)?, failure: ((NSError) -> Void)?){
        
        //        NetworkManager.defaultManager?.POST("UpdateServiceTrainMachine", parameters: ["serviceid":serviceid,"MachineKind":MachineKind,"MachineBrand":MachineBrand,"UserPhone":UserPhone], success: { (data) in
        //                    print(data)
        //            success!()
        //            }, failure: { (error) in
        //                print(error)
        //                failure!(error)
        //        })
        _ =   NetworkManager.defaultManager?.POST("GetServiceRecordByServiceTrain", parameters: ["servicecode":servicecode,"pageindex":pageindex,"pagesize":pagesize], success: {
            data in
            // print(data)
            let tmpData = data["data"].array
            //                                                print(tmpData)
            var orders=[Order]()
            for item in tmpData!{
                let orderId=item["OrderId"].stringValue
                let order = Order.cachedObjectWithID(orderId as NSString)
                var tmpUser = item["user"]
                order.city = item["city"].stringValue
                order.describe = item["Describe"].stringValue
                
                
                let homeTime = item["hometime"]
                // order.appointmentTime = homeTime["hometime"].stringValue
                if  homeTime["hometime"].stringValue == ""{
                    
                    order.appointmentTime = item["ServiceTime"].stringValue
                }else{
                    order.appointmentTime = homeTime["hometime"].stringValue
                }
                
                order.province = item["Province"].stringValue
                order.country = item["Country"].stringValue
                order.id = item["OrderId"].stringValue//OrderId
                var tmpUrl  = tmpUser["headimageurl"].stringValue
                if (tmpUrl != "")//headimageurl
                {
                    if (tmpUrl.contains("http"))==false
                    {
                        if let _ = (NetworkManager.defaultManager?.website) {
                            
                            tmpUrl = (NetworkManager.defaultManager?.website)!+tmpUrl
                        }else{
                            tmpUrl = SERVICEADDRESS + tmpUrl
                        }
                    }
                    order.headimageurl = tmpUrl //NSData(contentsOfURL: NSURL(string: tmpUrl)!)
                }
                else
                {
                    order.headimageurl = ""
                }
                order.checkState = item["CRMCheck"].stringValue
                order.productName = item["productinfo"]["ProductName"].stringValue
                order.productModel = item["productinfo"]["ProductModel"].stringValue
                order.createTime = item["CreateTime"].stringValue
                order.address = item["Address"].stringValue
                // order.describe = item["Describe"].stringValue
                order.modifyTime = item["ModifyTime"].stringValue
                order.distance = item["distance"].stringValue
                let troubleHandle = item["ServiceItem"].stringValue
                order.serviceItem     = troubleHandle
                order.lat=(item["lat"].stringValue as NSString).doubleValue as NSNumber?
                order.lng=(item["lng"].stringValue as NSString).doubleValue as NSNumber?
                orders.append(order)
                
            }
            
            success!(orders)
        }, failure: { (error) in
            //                print(error)
            
            failure!(error)
        })
        
    }
    
    //
    class func GetOrderNewDetails(_ orderid: String, success: ((Order) -> Void)?, failure: ((NSError) -> Void)?){
        _ =   NetworkManager.defaultManager!.POST("GetOrderDetails",parameters:["orderid":orderid],success: {data in
            //数组
            //            print(data)
            let item =   data["data"]
            let order = Order.cachedObjectWithID(item["id"].stringValue as NSString)
            
            order.headimageurl = item["user"]["headimageurl"].stringValue
            order.lat = item["lat"].numberValue
            order.lng = item["lng"].numberValue
            order.serviceItem = item["ServiceItem"].stringValue
            order.checkState = item["CRMCheck"].stringValue
            order.id = item["OrderId"] .stringValue
            success!(order)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    // 获取订单待支付详情信息
    
    class func GetOrderNoPayDetails(_ orderid: String, success: ((RNPayOrderModel,Int) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("GetOrderShouldPayMoney",parameters:["orderid":orderid],success: {data in
            //数组
            // print(data)
            //let item =   data["data"]
            let orderPayModel = RNPayOrderModel()
            orderPayModel.payInfos = [RNPAYDetailModel]()
            
            orderPayModel.orderId = data["Orderid"].stringValue
            orderPayModel.orderName = data["PayTitle"].stringValue
            orderPayModel.payMoney = data["PayMoney"].floatValue
            
            let isNeedPay = data["state"].intValue
            
            let json = data["data"].array
            
            var dataSource = [RNPAYDetailModel]()
            
            if json != nil {
                
                for item in json!{
                    let model = RNPAYDetailModel()
                    
                    model.id = item["id"].stringValue
                    model.orderId = item["OrderId"].stringValue
                    model.PayTitle = item["PayTitle"].stringValue
                    model.UserId = item["UserId"].stringValue
                    model.Money = item["Money"].floatValue
                    model.OriMoney = item["OriMoney"].floatValue
                    model.PayState = item["PayState"].stringValue
                    model.Payway = item["Payway"].stringValue
                    
                    dataSource.append(model)
                }
                
                
            }
            
            orderPayModel.payInfos = dataSource
            
            success!(orderPayModel,isNeedPay)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    
    
    // 获取微信支付所需提交字段信息
    
    class func GetWeixinPayInfos(_ orderid: String, success: ((RNWeixinModel) -> Void)?, failure: ((NSError) -> Void)?){
        _ =   NetworkManager.defaultManager!.POST("WechatAppPrePay",parameters:["orderid":orderid],success: {data in
            //数组
            // print(data)
            let item =   data["data"]
            let weixinModel = RNWeixinModel()
            weixinModel.queryid = item["queryid"].stringValue
            weixinModel.noncestr = item["noncestr"].stringValue
            weixinModel.appid = item["appid"].stringValue
            weixinModel.sign = item["sign"].stringValue
            weixinModel.partnerid = item["partnerid"].stringValue
            weixinModel.timestamp = item["timestamp"].stringValue
            weixinModel.prepayid = item["prepayid"].stringValue
            weixinModel.pkg = item["package"].stringValue
            
            
            success!(weixinModel)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    
    // 支付结果查询
    class func GetPayResults(_ queryid: String,queryseconds: String, success: ((RNPayResultsModel) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("WechatQueryPayResult",parameters:["queryid":queryid, "queryseconds":queryseconds],success: {data in
            //数组
            // print(data)
            // let item =   data["data"]
            let payResultsModel = RNPayResultsModel()
            
            
            success!(payResultsModel)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    //AlipayAppPrePay
    class func GetAlipayPayInfos(_ orderid: String, success: ((AlipayOrder) -> Void)?, failure: ((NSError) -> Void)?){
        _ =   NetworkManager.defaultManager!.POST("AlipayAppPrePay",parameters:["orderid":orderid],success: {data in
            //数组
            // print(data)
            let item = data["data"]
            
            let alipaynModel = AlipayOrder()
            alipaynModel.app_id = item["app_id"].stringValue
            
            
            let bizContent  = BizContent()
            let contentString = item["biz_content"].stringValue
            // alipaynModel.biz = contentString
            let content = JSON.init(parseJSON: contentString)
            bizContent.body = content["body"].stringValue
            bizContent.subject = content["subject"].stringValue
            bizContent.out_trade_no = content["out_trade_no"].stringValue
            bizContent.timeout_express = content["timeout_express"].stringValue
            bizContent.total_amount = content["total_amount"].stringValue
            bizContent.product_code = content["product_code"].stringValue
            
            alipaynModel.biz_content = bizContent
            alipaynModel.charset = item["charset"].stringValue
            alipaynModel.format = item["format"].stringValue
            alipaynModel.method = item["method"].stringValue
            alipaynModel.notify_url = item["notify_url"].stringValue
            alipaynModel.sign_type = item["sign_type"].stringValue
            
            let timestamp  = item["timestamp"].stringValue
            alipaynModel.timestamp =  timestamp.replacingOccurrences(of: "/", with: "-")
            // alipaynModel.timestamp =  timestamp.stringByReplacingOccurrencesOfString("/", withString: "-")
            
            alipaynModel.version = item["version"].stringValue
            alipaynModel.sign = item["sign"].stringValue
            
            success!(alipaynModel)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    // 我的车辆
    class func GetMyCarInfo(_ success: ((([String], String)) -> Void)?, failure: ((NSError) -> Void)?){
        
        _ =   NetworkManager.defaultManager!.POST("GeCarInfo",parameters:nil,success: {data in
            //数组
            // print(data)
            let item =   data["data"]
            var arr = [String]()
            // 按顺序获取
            
            arr.append(item["UserId"].stringValue )
            arr.append(item["Name"].stringValue )
            arr.append(item["VehicleBrand"].stringValue )
            arr.append(item["VehiclePlate"].stringValue )
            arr.append(item["EngineNumber"].stringValue )
            arr.append(item["VIN"].stringValue )
            arr.append(item["GPSSource"].stringValue )
            
            let timeStr = item["IssueDate"].stringValue
            if (timeStr.hasPrefix("/Date(") || timeStr.hasPrefix("\\Date("))  && (timeStr as NSString).length >= 9 {
                let timeStamp = DateTool.dateFromServiceTimeStamp(timeStr)!
                arr.append(DateTool.stringFromDate(timeStamp, dateFormat: "yyyy年MM月dd日 HH:mm"))
            }else{
                arr.append(item["IssueDate"].stringValue )
            }
            
            arr.append(item["PolicyNumber"].stringValue )
            arr.append(item["ComPolicyNumber"].stringValue )
            arr.append(item["PolicyExtime"].stringValue )
            arr.append(item["CompanyName"].stringValue )
            arr.append(item["ServiceArea"].stringValue )
            
            let timestr02 = item["InspectionTime"].stringValue
            if (timestr02.hasPrefix("/Date(") || timestr02.hasPrefix("\\Date("))  && (timestr02 as NSString).length >= 9 {
                let timeStamp = DateTool.dateFromServiceTimeStamp(timestr02)!
                arr.append(DateTool.stringFromDate(timeStamp, dateFormat: "yyyy年MM月dd日 HH:mm"))
            }else{
                arr.append(item["InspectionTime"].stringValue )
            }
            
            
            arr.append(item["Extend1"].stringValue )
            arr.append(item["Extend1"].stringValue )
            
            
            let picture = item["VI"].stringValue
            
            success!((arr, picture))
            
        },  failure:{ (error) in
            failure!(error)
        })
        
    }
    
    // 无服务完成订单 NoServiceFinshOrder
    
    class func NoServiceFinshOrder(_ orderid:String, service: String, success: (() -> Void)?, failure: ((NSError) -> Void)?){
        
        _ =  NetworkManager.defaultManager!.POST("NoServiceFinshOrder",parameters:["orderid":orderid, "service":service],success: {data in
            
            success!()
            
        },  failure:{ (error) in
            failure!(error)
        })
        
    }
    
    
    
    /// 安装水机获取验证码
    ///
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - order: 获取用途 - QianYeUserInstall
    ///   - scope: 角色 -- 可选
    class func GetCodeForInstallingMachine(mobile: String, order: String, scope: String?, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        var params = ["mobile": mobile, "order": order]
        if let scope = scope {
            params["scope"] = scope
        }
        
        _ =  NetworkManager.defaultManager!.POST("SendPhoneCodeForInstallMachine",parameters: params as NSDictionary,success: {data in
            
            success!()
            
        },  failure:{ (error) in
            failure!(error)
        })
        
    }
    
    /// 提交安装信息
    ///
    /// - Parameter jsonStr: 参数信息的 json串
    class func SubmitInstallInfo(jsonStr: String, success: (() -> Void)?, failure: ((NSError) -> Void)?){
        
        _ =  NetworkManager.defaultManager!.POST("GetQYInstallInfo",parameters: ["JsonStr": jsonStr],success: {data in
            
            success!()
            
        },  failure:{ (error) in
            failure!(error)
        })
        
    }
    
    
    /// 获取用户身份标识
    ///
    /// - Paramter userId: userid
    class func MemberIdentifier(userid: String, success: ((UserIdentifier) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("MemberIdentifier",parameters: ["userid": userid],success: {data in
            
            let dataContent = data["data"]
            let userIdentifier =  UserIdentifier.cachedObjectWithID(dataContent["UserId"].stringValue as NSString)
            
            userIdentifier.identifier = data["state"].stringValue
            // 1 = 该用户为团队创建人
            // 2 = 该用户为小组负责人
            // 3 = 该用户为小组成员
            // 4 = 该用户未在任何团队中
            
            switch userIdentifier.identifier {
            case "1"?:
                userIdentifier.groupId = dataContent["GroupNumber"].stringValue
                //userIdentifier.userId = dataContent["UserId"].stringValue
               // userIdentifier.scope = dataContent["GroupScope"].stringValue
                userIdentifier.state = dataContent["GropState"].stringValue
                
                break
            case "2"?:
                userIdentifier.groupId = dataContent["TeamID"].stringValue
               // userIdentifier.userId = dataContent["UserId"].stringValue
              //  userIdentifier.scope = dataContent["GroupScope"].stringValue
                userIdentifier.state = dataContent["AuditState"].stringValue
                break
            case  "3"?:
                userIdentifier.groupId = dataContent["TeamID"].stringValue
               // userIdentifier.userId = dataContent["UserId"].stringValue
               // userIdentifier.scope = dataContent["GroupScope"].stringValue
                userIdentifier.state = dataContent["State"].stringValue
                break
            default:
                break
            }
            
            
            success!((userIdentifier))
            
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    // 小组列表 - 团队
    class func GetGroupListInTeam(groupId: String, success: (([GroupDetail]) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("GetGroupListInTeam",parameters: ["groupid": groupId],success: {data in
            
            let dataContent = data["data"].array
            
            var dataArray = [GroupDetail]()
            for item in dataContent! {
                let model = GroupDetail()
                model.groupName = item["TeamName"].stringValue
                model.groupId = item["TeamID"].stringValue
                model.leaderId = item["LeaderID"].stringValue
                dataArray.append(model)
            }
            
            success!(dataArray)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    // 成员列表 - 小组
    class func GetTeamMemberList(teamId: String, success: (([TeamMembers]) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("GetTeamMemberList",parameters: ["teamid": teamId],success: {data in
            
            let dataContent = data["data"].array
            
            var dataArray = [TeamMembers]()
            
            if let content = dataContent {
                
                for item in content {
                    let model = TeamMembers()
                    model.headimageurl = item["headimgurl"].stringValue
                    model.userid = item["engineerid"].stringValue
                    model.nickname = item["realname"].stringValue
                    model.title = item["partnertype"].stringValue
                    dataArray.append(model)
                }
                
            }
            
            success!(dataArray)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    // 团队详情
    class func GetTeamDetails(teamId: String, success: ((GroupDetail) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("GetGroupDetails",parameters: ["groupid": teamId],success: {data in
            
            let dataContent = data["data"]
            
            let model = GroupDetail()
            
            model.groupId = dataContent["GroupId"].stringValue
            model.groupName = dataContent["GroupName"].stringValue
            model.leaderName = dataContent["LeaderName"].stringValue
            model.mobile = dataContent["LeaderPhone"].stringValue
            model.title = dataContent["PartnerType"].stringValue
            model.serviceArea = [RNServiceAreasModel]()
            
            let areas = dataContent["servicearea"].array
            
            if let arr = areas {
                
                var dataAreas = [RNServiceAreasModel]()
                for item in arr {
                    let areaModel = RNServiceAreasModel()
                    areaModel.id = item["id"].stringValue
                    areaModel.address = item["Address"].stringValue
                    areaModel.province = item["Province"].stringValue
                    areaModel.city = item["City"].stringValue
                    areaModel.country = item["Country"].stringValue
                    areaModel.latitude = item["lat"].stringValue
                    areaModel.longtitue = item["lng"].stringValue
                    dataAreas.append(areaModel)
                }
                model.serviceArea = dataAreas
            }
            
            
            success!(model)
        },  failure:{ (error) in
            failure!(error)
        })
    }

    
    // 小组详情
    class func GetGroupDetails(teamId: String, success: ((GroupDetail) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("GetTeamDetails",parameters: ["teamid": teamId],success: {data in
            
            let dataContent = data["data"]
            
            let model = GroupDetail()
            
            model.groupId = dataContent["teamid"].stringValue
            model.groupName = dataContent["teamname"].stringValue
            model.leaderName = dataContent["leadername"].stringValue
            model.mobile = dataContent["mobile"].stringValue
            model.title = dataContent["partnertype"].stringValue
            model.serviceArea = [RNServiceAreasModel]()
            
            let areas = dataContent["servicearea"].array
            
            if let arr = areas {
                
                var dataAreas = [RNServiceAreasModel]()
                for item in arr {
                    let areaModel = RNServiceAreasModel()
                    areaModel.id = item["id"].stringValue
                    areaModel.address = item["Address"].stringValue
                    areaModel.province = item["Province"].stringValue
                    areaModel.city = item["City"].stringValue
                    areaModel.country = item["Country"].stringValue
                    areaModel.latitude = item["lat"].stringValue
                    areaModel.longtitue = item["lng"].stringValue
                    dataAreas.append(areaModel)
                }
                model.serviceArea = dataAreas
            }
            
            
            success!(model)
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    // 成员详情
    class func GetTeamMemberDetails(userid: String, success: ((TeamMembers) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("GetTeamMemberDetails",parameters: ["userid": userid],success: {data in
            
            let dataContent = data["data"]
            
            let model = TeamMembers()
            
            model.mobile = dataContent["mobile"].stringValue
            model.serviceArea = [RNServiceAreasModel]()
            
            let areas = dataContent["servicearea"].array
            
            if let arr = areas {
                
                var dataAreas = [RNServiceAreasModel]()
                for item in arr {
                    let areaModel = RNServiceAreasModel()
                    areaModel.id = item["id"].stringValue
                    areaModel.address = item["Address"].stringValue
                    areaModel.province = item["Province"].stringValue
                    areaModel.city = item["City"].stringValue
                    areaModel.country = item["Country"].stringValue
                    areaModel.latitude = item["lat"].stringValue
                    areaModel.longtitue = item["lng"].stringValue
                    dataAreas.append(areaModel)
                }
                model.serviceArea = dataAreas
            }
            
            
            success!(model)
            
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    
    class func QueryTeamList(query: String, success: (([GroupDetail]) -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("QueryTeamList",parameters: ["query": query],success: {data in
            
            let dataContent = data["data"].array
            
            var dataArray = [GroupDetail]()
            for item in dataContent! {
                let model = GroupDetail()
                model.groupName = item["TeamName"].stringValue
                model.groupId = item["TeamId"].stringValue
                model.leaderId = item["LeaderID"].stringValue
                dataArray.append(model)
            }
            
            success!(dataArray)
        },  failure:{ (error) in
            failure!(error)
        })
    }

    // 加入小组
    class func JoinTeam(teamId: String, success: (() -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("JoinTeam",parameters: ["teamid": teamId],success: {data in
            
            success!()
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    
    // 创建团队
    class func CreateTeam(params: [String: Any], success: (() -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("CreateGroup",parameters: params as NSDictionary,success: {data in
            
            success!()
        },  failure:{ (error) in
            failure!(error)
        })
    }

    // 创建小组
    class func CreateGroup(params: [String: Any], success: (() -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("CreateTeam",parameters: params as NSDictionary ,success: {data in
            
            success!()
        },  failure:{ (error) in
            failure!(error)
        })
    }
    
    // 移除成员
    class func SignOutTeam(userid: String, success: (() -> Void)?, failure: ((NSError) -> Void)?){
        _ =  NetworkManager.defaultManager!.POST("SignOutTeam",parameters: ["userid": userid], success: {data in
            
            success!()
        },  failure:{ (error) in
            failure!(error)
        })
    }

    
    //GetPost/Command/BindNewBlankCard绑定银行卡
    class func BindNewBlankCard2(_ paramDic: [String: Any], success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ = NetworkManager.defaultManager!.POST("BindNewBlankCard2",
                                                parameters:paramDic as NSDictionary,
                                                success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                failure: failure)
    }
    

    class func RobOrderV2(_ orderid: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =   NetworkManager.defaultManager!.POST("RobOrderV2",
                                                  parameters:["orderid":orderid],
                                                  success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                  failure: failure)
    }
    
    //GetWaterValueInfo
    class func GetWaterValueInfo(_ phone: String , success: ((String) -> Void)?, failure: ((NSError) -> Void)?) {
        _ =   NetworkManager.defaultManager!.POST("GetWaterValueInfo",
                                                  parameters:["mobile":phone],
                                                  success: {
                                                    data in
                                                   let waterValue = data["data"]["Data"]["days"].stringValue
                                                    success!(waterValue)
        },
                                                  failure: failure)
    }

    
    // CreateWaterCard
    class func CreateWaterCard(_ phone: String ,mac: String, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        _ =   NetworkManager.defaultManager!.POST("CreateWaterCard",
                                                  parameters:["mobile":phone, "mac": mac],
                                                  success: {
                                                    data in
                                                    //  print(data)
                                                    success!()
        },
                                                  failure: failure)
    }

}
