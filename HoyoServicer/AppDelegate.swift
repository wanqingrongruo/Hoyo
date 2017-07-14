//
//  AppDelegate.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import CoreData
import Reachability
import SwiftyJSON
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


//// 当前支付状态的枚举
//enum CURRENT_PAY_TYPE : Int{
//    case NONE = 0 // 未支付
//    case ALIPAY = 1 // 支付宝支付
//    case WEIXIN = 2 // 微信支付
//}
//
enum PushType {
    /// 普通
    case string
    /// 积分
    case score
    /// 指派订单
    case ordernotify
    /// 可抢订单
    case orderrob
}

//var Current_pay_type :CURRENT_PAY_TYPE = .NONE // 默认未选择支付方式
//var isSuccessWithPayType = false // 选择了支付方式后是否支付成功


var appDelegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate{
    
    var window: UIWindow? = {
        let v = UIWindow(frame: UIScreen.main.bounds)
        return v
    }()
    
    
    
    lazy var loginViewController: LoginAndRegisterViewController = {
        
        return    LoginAndRegisterViewController.init(nibName: "LoginAndRegisterViewController", bundle: nil)
    }()
    /// 网络状态
    var reachOfNetwork:Reachability?
    //主视图控制器
    var mainViewController: MainViewController!
    
    var pushType: PushType?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Bugly.start(withAppId: "900029559")
        
        //检查网络状况，无网络，wifi，普通网络三种情况实时变化通知
        reachOfNetwork = Reachability(hostName: "www.baidu.com")
        reachOfNetwork!.startNotifier()
        
        //网络变化通知，在需要知道的地方加上此通知即可
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        
        
        //提醒用户给app打分//
        //        Appirater.setAppId("955305764")
        //        Appirater.setDaysUntilPrompt(1)
        //        Appirater.setUsesUntilPrompt(1)
        //        Appirater.setSignificantEventsUntilPrompt(-1)
        //        Appirater.setTimeBeforeReminding(2)
        //        Appirater.setDebug(true)
        //        Appirater.appLaunched(true)
        
        //设置状态栏字体为白色
        UIApplication.shared.statusBarStyle=UIStatusBarStyle.lightContent
        
        //标记是否第一次登陆
        let isFristOpen = UserDefaults.standard.object(forKey: "isFristOpenApp")
        
        if isFristOpen == nil {
            let guideVC = RNGuideViewController()
            
            guideVC.skipClosure = { [weak self]() -> Void in
                
                UIView.animate(withDuration: 1.2, animations: {
                    
                    let newTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    guideVC.view.transform = newTransform
                    
                    }, completion: { (finished) in
                        self!.window!.rootViewController = self!.loginViewController
                        
                })
                
            }
            window?.rootViewController = guideVC
            UserDefaults.standard.set("isFristOpenApp", forKey: "isFristOpenApp")
        } else {
            
            User.loginWithLocalUserInfo(
                success: {
                    [weak self] user in
                    User.currentUser = user
                    
                    self?.window?.rootViewController = MainViewController()
                },
                failure: {[weak self] (error) in
                    
                    self?.window!.rootViewController = self?.loginViewController
                    
                })
        }
        //window!.rootViewController = loginViewController
        
        
        // 提示更新
        updateversion()
        
        
        window!.makeKeyAndVisible()
        
        
        //Required 判断当前设备版本
        if Float(UIDevice.current.systemVersion) >= 8.0 {
            
            let type:UInt = UIUserNotificationType.alert.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue
            
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
            
        } else {
            let type:UInt = UIUserNotificationType.alert.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue
            
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        //注册极光
        JPUSHService.setup(withOption: launchOptions, appKey: "78f40fd899d1598548afa084", channel: nil, apsForProduction: true)
        
        if (launchOptions != nil) {
            let remoteNotification = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification];
            UserDefaults.standard.setValue("HomeOrderNotification", forKey: OrderPushNotification)
            
            //这个判断是在程序没有运行的情况下收到通知，点击通知跳转页面
            if (remoteNotification != nil) {
                
            }
        }
        
        //关闭连接
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidClose(_:)), name: NSNotification.Name.jpfNetworkDidClose, object: nil)
        
        //注册成功
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidRegister(_:)), name: NSNotification.Name.jpfNetworkDidRegister, object: nil)
        
        //登陆成功
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidLogin(_:)), name: NSNotification.Name.jpfNetworkDidLogin, object: nil)
        
        //收到自定义消息
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidReceiveMessage(_:)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
        
        
        // 微信支付注册
        WXApi.registerApp("wx1baa87b7f1b6fad1", withDescription: "浩优支付")
        
//        // JSPatch 接入
//        JSPatch.start(withAppKey: "6e6d6664a2da393a")
//        JSPatch.sync()
        
        return true
    }
    
    /**
     登出处理
     */
    func LoginOut()
    {
        
        if appDelegate.mainViewController != nil{
            
            appDelegate.mainViewController.dismiss(animated: true, completion: nil)
            appDelegate.mainViewController = nil
            
            User.BingJgNotifyId("loginout", success: {
                print("绑定极光通知成功")
            }) { (error:NSError) in
                print(error)
            }
            
        }
        
        
        //清理用户文件
        
        NetworkManager.clearCookies()
        DataManager.defaultManager = nil
        window?.rootViewController = loginViewController
        //退出登录删除本地用户名和密码
        //        NSUserDefaults.standardUserDefaults().removeObjectForKey("UserName")
        //        NSUserDefaults.standardUserDefaults().removeObjectForKey("PassWord")
        
    }
    //接收到网络变化后处理事件
    func reachabilityChanged(_ notification:Notification){
        let reach = notification.object
        print(reachOfNetwork?.currentReachabilityString() ?? "")
        if (((reach as AnyObject).isKind(of: Reachability.classForCoder())) != false){
            
            let status:NetworkStatus = ((reach as AnyObject).currentReachabilityStatus()) //currentReachabilityStatus];
            
            switch status
            {
            case .NotReachable:
                print("网络不可用")
                break
            case .ReachableViaWiFi:
                print("WIFI已连接")
                break
            case .ReachableViaWWAN:
                print("普通网络已连接")
                break
                
            }
            
            
        }
        
    }
    
    // 应用间跳转回调
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        //       // isSuccessWithPayType = true
        //        Current_pay_type = .NONE
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        //       // isSuccessWithPayType = true
        //        Current_pay_type = .NONE
        if WXApi.handleOpen(url, delegate: self) {
            return true
        }else{
           
            if url.host == "safepay" {
                AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                    //
                })
            }
            
            return true
            
        }
    }
    
    // iOS9.0以后
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
       
        if WXApi.handleOpen(url, delegate: self) {
            return true
        }else{
            
            if url.host == "safepay" {
                AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                    //
                })
            }
            
            return true
            
        }

    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
        application.cancelAllLocalNotifications()
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
        application.cancelAllLocalNotifications()
        
      
        // 推荐更新
      //  updateversion()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if UserDefaults.standard.value(forKey: UserDefaultsUserIDKey) != nil {
            DataManager.defaultManager.saveChanges()
        }
        
    }
    
    
    
    
    //MARK: - 极光通知方法
    //注册推送消息
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("deviceToken:\(deviceToken)")
        //        let registraID = JPUSHService.registrationID()
        JPUSHService.registerDeviceToken(deviceToken)
        print("注册设备成功")
    }
    
    //推送消息成功后调用
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("程序在前台zhu" + "\(userInfo)")
        JPUSHService.handleRemoteNotification(userInfo)
        
    }
    
    //iOS 7.0方法
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == UIApplicationState.active {
            //            AudioServicesDisposeSystemSoundID(1007);
            
            if let pushGY = pushType {
                switch pushGY {
                case PushType.orderrob:
                    //建立的SystemSoundID对象
                    var soundID:SystemSoundID = 0
                    //获取声音地址
                    let path = Bundle.main.path(forResource: "message", ofType: "wav")
                    //地址转换
                    let baseURL = URL(fileURLWithPath: path!)
                    //赋值
                    AudioServicesCreateSystemSoundID(baseURL as CFURL, &soundID)
                    //播放声音
                    AudioServicesPlaySystemSound(soundID)
                case PushType.string,PushType.ordernotify,PushType.score:
                    //                    AudioServicesDisposeSystemSoundID(1007)
                    AudioServicesPlaySystemSound(1007)
                }
            }
            
            completionHandler(UIBackgroundFetchResult.newData)
            
        } else if application.applicationState == UIApplicationState.background{
            JPUSHService.handleRemoteNotification(userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
            //            print("程序在后台ZHU" + "\(userInfo)")
            //            print(userInfo["aps"]!["alert"])
            pushSoundAction()
            
        } else {
            completionHandler(UIBackgroundFetchResult.newData)
            pushSoundAction()
            
        }
    }
    
    func pushSoundAction() {
        if let pushGY = pushType {
            switch pushGY {
            case PushType.orderrob:
                NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotification), object: nil,userInfo: nil)
                
            case PushType.string,PushType.score:
                NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotificationString), object: nil,userInfo: nil)
            case PushType.ordernotify:
                
                let alert = SCLAlertView()
                alert.addButton("确定", action: {})
                alert.showInfo("温馨提示", subTitle: "您有新的指派订单，请查看首页->待处理!")
                break
            }
        } else {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotification), object: nil,userInfo: nil)
        }
    }
    
    //注册推送失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Errorwd:\(error)")
    }
    
    //MARK: - 极光推送监听
    
    func JPushDidSetup(_ noti:Notification)
    {
        print("建立连接")
    }
    
    func JPushDidClose(_ noti:Notification)  {
        print("关闭连接")
    }
    
    func JPushDidRegister(_ noti:Notification)  {
        print("注册成功")
    }
    func JPushDidLogin(_ noti:Notification)  {
        //        print("登录成功")
        //        print("🐷" + "registraID:\(JPUSHService.registrationID())")
        //        print(User.currentUser?.usertoken)
        User.BingJgNotifyId(JPUSHService.registrationID(), success: {
            print("绑定极光通知成功")
        }) { (error:NSError) in
            print(error)
        }
    }
    
    //MARK: - 接受自定义消息和通知消息
    func JPushDidReceiveMessage(_ noti:Notification)  {
        
        let tmp = noti.userInfo!["content"] as! String
        if  let data = tmp.data(using: String.Encoding.utf8) {
            let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
            let userId = dic!!["SendUserid"]?.stringValue ?? ""
            let strNum =  MessageModel.updateSource(userId, entityName: "") 
            
            let model = MessageModel.cachedObjectWithID(dic!!["MsgId"] as! NSString)
            model.sendUserid = dic!!["SendUserid"]?.stringValue ?? ""
            model.msgId = dic!!["MsgId"] as? String ?? ""
            
            model.recvUserid = dic!!["RecvUserid"]?.stringValue ?? ""
            model.sendNickName = dic!!["SendNickName"] as? String ?? ""
            model.messageType = dic!!["MessageType"] as? String ?? ""
            model.sendImageUrl = dic!!["SendImageUrl"] as? String ?? ""
            if model.messageType == "score" {
                if model.sendImageUrl != "" && (model.sendImageUrl?.contains(SERVICEADDRESS))!{
                    model.sendImageUrl =  model.sendImageUrl!
                } else {
                    model.sendImageUrl = SERVICEADDRESS +  model.sendImageUrl!
                }
            } else {
                if model.sendImageUrl != "" {
                    model.sendImageUrl = SERVICEADDRESS +  model.sendImageUrl!
                }
            }
            
            if let typeGY = model.messageType {
                
                switch  typeGY {
                case "string":
                    pushType = PushType.string
                case "score":
                    pushType = PushType.score
                case "ordernotify":
                    pushType = PushType.ordernotify
                case "orderrob":
                    pushType = PushType.orderrob
                    
                default:
                    break
                }
            }
            
            model.messageCon = dic!!["MessageCon"] as? String ?? ""
            model.createTime = dic!!["CreateTime"] as? String ?? ""
            model.messageNum = String(Int(strNum)! + 1)
            
            let scoreModel = ScoreMessageModel.cachedObjectWithID(dic!!["MsgId"] as! String as NSString)
            scoreModel.msgId = dic!!["MsgId"] as? String ?? ""
            scoreModel.sendUserid = dic!!["SendUserid"]?.stringValue ?? ""
            scoreModel.recvUserid = dic!!["RecvUserid"]?.stringValue ?? ""
            scoreModel.sendNickName = dic!!["SendNickName"] as? String ?? ""
            scoreModel.sendImageUrl = dic!!["SendImageUrl"] as? String ?? ""
            if scoreModel.sendImageUrl != "" {
                scoreModel.sendImageUrl = SERVICEADDRESS +  scoreModel.sendImageUrl!
            }
            scoreModel.messageCon = dic!!["MessageCon"] as? String ?? ""
            scoreModel.messageType = dic!!["MessageType"] as? String ?? ""
            scoreModel.createTime = dic!!["CreateTime"] as? String ?? ""
            scoreModel.remark = dic!!["Remark"] as? String ?? ""
            DataManager.defaultManager!.saveChanges()
            print("进入了")
            // 后台前台都进，会导致声音重复
            //            AudioServicesPlaySystemSound(1007)
            NotificationCenter.default.post(name: Notification.Name(rawValue: messageNotification), object: nil, userInfo: ["messageNum": "1"])
            
        }
        
    }
    
    //回调函数
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        print("回调了")
    }
    
    
//    //版本更新
//    func CheckVerion() {
//        let storeString = "http://itunes.apple.com/lookup?id=1116961418"
//        let storeURL = URL(string: storeString)
//        let request = NSMutableURLRequest(url: storeURL!)
//        request.httpMethod = "GET"
//        //        let queue = NSOperationQueue()
//        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error1) in
//            do {
//                
//                
//                let appData =   try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
//                
//                DispatchQueue.main.async(execute: {
//                    
//                    guard appData!["results"]![0] != nil else {
//                        return
//                    }
//                    
//                    let versionsInAppStore = appData!["results"]![0]["version"] as? String
//                    
//                    let version1 = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
//                    
//                    let describeStr = appData!["results"]![0]["releaseNotes"] as? String ?? ""
//                    
//                    if versionsInAppStore?.compare(version1!) == ComparisonResult.orderedAscending {
//                        print("已是最新")
//                    } else {
//                        let alertView = SCLAlertView()
//                        alertView.addButton("前往更新 ", action: {
//                            let url = "https://itunes.apple.com/cn/app/fm-lu-xing-jie-ban-lu-xing/id1116961418?mt=8";
//                            UIApplication.shared.openURL(URL(string: url)!)
//                            
//                        })
//                        alertView.addButton("取消", action: {})
//                        
//                        alertView.showInfo("发现新版本" + versionsInAppStore!, subTitle: describeStr)
//                    }
//                    
//                })
//            }catch let error1 as NSError{
//                print(error1)
//            }
//            
//            })  as URLSessionTask
//        
//        dataTask.resume()
//        /*
//         NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error1) in
//         
//         do {
//         let appData =   try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
//         print(appData!)
//         dispatch_async(dispatch_get_main_queue(), {
//         let versionsInAppStore = appData!["results"]![0]["version"] as? String
//         print(versionsInAppStore)
//         
//         let version1 = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
//         print(version1)
//         if versionsInAppStore  == version1 {
//         print("已是最新")
//         } else {
//         print("更新")
//         }
//         
//         })
//         }catch let error1 as NSError{
//         print(error1)
//         }
//         
//         }
//         
//         */
//    }
//    
    
    /************************************/
    // 微信支付回调
    
    
    // 微信支付回调
    
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: PayResp.self) {
            let response = resp as! PayResp
            switch  response.errCode {
            case WXSuccess.rawValue:
                
                // 发出微信支付成功通知
                NotificationCenter.default.post(name: Notification.Name(rawValue: "WEIXINPAYSUCCESS"), object: nil)
                break
                
            default:
                
                // 发出微信支付失败通知
                NotificationCenter.default.post(name: Notification.Name(rawValue: "WEIXINPAYFAIL"), object: nil)
                
                break
                
            }
            
        }
    }
    
    // 版本更新提示
    func updateversion(){
        
        let session = URLSession.shared
        
        let url = URL(string: "https://api.github.com/repos/ozner-app-ios-org/updateApi/contents/HoyoUpdateFile/hoyo.json")
        guard let u = url else{
            return
        }
        
        let request = NSMutableURLRequest(url: u)
        
        request.httpMethod = "GET"
        request.timeoutInterval = 10 
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, resopnse, error) in
            
            guard let _ = data else{
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                
                let str = ((json as! [String:AnyObject])["content"] as? String)?.replacingOccurrences(of: "\n", with: "")
                
                guard let s = str else{
                    return
                }
                
                //解码
                let edcodeData = Data(base64Encoded: s, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                let decodedString = String(data: edcodeData!, encoding: String.Encoding.utf8)
                
                let data2 = decodedString?.data(using: String.Encoding.utf8)
                
                guard let _ = data2 else{
                    return
                }
                
                let dic = JSON(data: data2!)
                let versionsInAppStore = dic["result"]["version"].stringValue
                let desc = dic["result"]["updateDesc"].stringValue
                let updateType = dic["result"]["updateType"].stringValue
                let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
                
                guard let _ = currentVersion else{
                    return
                }
                
                //  比较 -- A.compare(B) => 按照 A B 排列, A > B => orderedDescending
                if versionsInAppStore.compare(currentVersion!) == ComparisonResult.orderedDescending {
                   
                    if updateType == "optional"{
                        
                        
                        DispatchQueue.main.async(execute: {
                            let alertView = SCLAlertView()
                            alertView.addButton("前往更新 ", action: {
                                let url = "https://itunes.apple.com/cn/app/fm-lu-xing-jie-ban-lu-xing/id1116961418?mt=8";
                                UIApplication.shared.openURL(URL(string: url)!)
                                
                            })
                            alertView.addButton("取消", action: {})
                            
                            alertView.showInfo("发现新版本" + versionsInAppStore, subTitle: desc)
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
                            let alertView = SCLAlertView()
                            alertView.addButton("前往更新 ", action: {
                                let url = "https://itunes.apple.com/cn/app/fm-lu-xing-jie-ban-lu-xing/id1116961418?mt=8";
                                UIApplication.shared.openURL(URL(string: url)!)
                                
                            })
                            
                            alertView.showInfo("发现新版本" + versionsInAppStore, subTitle: "此版本需要强制更新")
                            
                            //                            let alertView = UIAlertController(title: "发现新版本" + versionsInAppStore, message: "此版本需要强制更新", preferredStyle: UIAlertControllerStyle.Alert)
                            //                            let okAction = UIAlertAction(title: "前往更新", style: UIAlertActionStyle.Default, handler: { (action) in
                            //                                let url = "https://itunes.apple.com/cn/app/fm-lu-xing-jie-ban-lu-xing/id1116961418?mt=8";
                            //                                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                            //                            })
                            //                            alertView.addAction(okAction)
                            //                            self.presentViewController(alertView, animated:true, completion: nil)
                        })
                    }

                } else {
                    
                     // print("已是最新")
                    
                }
                
                
            }
            catch let error1 as NSError{
                print(error1)
            }
        }) 
        
        task.resume()
        
        
    }
    
    
    
}

