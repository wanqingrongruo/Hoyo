//
//  NetworkManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/10/7.
//  Copyright (c) 2015年 BetaTech. All rights reserved.
//


import Foundation
import SwiftyJSON

/// 网络访问基类
class NetworkManager: NSObject {
    required init?(NetworkConfig: NSDictionary) {
        
        self.NetworkConfig = NetworkConfig
        super.init()
        
    }
    static var defaultManager = NetworkManager(NetworkConfig: NSDictionary(contentsOfFile: Bundle.main.path(forResource: "NetworkConfig", ofType: "plist")!)!)
    
    func GET(_ key: String,
             parameters: NSDictionary?,
             success: ((JSON) -> Void)?,
             failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
        return request(key,
                       GETParameters: parameters,
                       POSTParameters: nil,
                       constructingBodyWithBlock: nil,
                       success: success,
                       failure: failure)
    }
    func POST(_ key: String,
              parameters: NSDictionary?,
              success: ((JSON) -> Void)?,
              failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
        return request(key,
                       GETParameters: nil,
                       POSTParameters: parameters,
                       constructingBodyWithBlock: nil,
                       success: success,
                       failure: failure)
    }
    func request(_ key: String,
                 GETParameters: NSDictionary?,
                 POSTParameters: NSDictionary?,
                 constructingBodyWithBlock block: ((AFMultipartFormData?) -> Void)?,
                                           success: ((JSON) -> Void)?,
                                           failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation? {
        
        var error: NSError? = nil
        let URLString = manager.requestSerializer.request(withMethod: "GET", urlString: paths[key]!, parameters: GETParameters, error: &error).url?.absoluteString
        if error != nil || URLString == nil {
            failure?(error!) // Needs specification
            return nil
        }
       // 
        
        
        // 添加token
        let tmpParameters = NSMutableDictionary(dictionary: POSTParameters ?? NSDictionary())
        tmpParameters.setObject(userToken, forKey: UserDefaultsUserTokenKey as NSCopying)
        print(tmpParameters)
        print("上面的输出语句输在 NetworkManager 文件的第 64 行")
        return manager.post(URLString!,
                            parameters: tmpParameters,
                            constructingBodyWith: block,
                            success: {
                                [weak self] operation, data in
                                self?.handleSuccess(operation: operation, data: (data as! NSData) as Data, success: success, failure: failure)
                                
                                
            },
                            failure: {
                                [weak self] operation, error in
                                if appDelegate.reachOfNetwork?.currentReachabilityStatus().rawValue==0
                                {//网络未连接错误
                                    let userInfo = [
                                        NSLocalizedDescriptionKey: self?.getErrorState(-40404) ?? "网络未连接",
                                        NSURLErrorKey: ""
                                        
                                    ]
                                    let tmperror = NSError(
                                        domain: (self?.website) ?? SERVICEADDRESS,
                                        code: -40404,
                                        userInfo: userInfo)
                                    
                                   // if failure != nil{
                                        failure?(tmperror)
                                   // }
                                    
                                }else{//网络连接，其它原因
                                    failure?(error as NSError)
                                }
                                
            })
    }
    fileprivate func handleSuccess(operation: AFHTTPRequestOperation, data: Data, success: ((JSON) -> Void)?, failure: ((NSError) -> Void)?) {
        let error: NSError? = nil
        let object: AnyObject?
        do{
            object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        }
        catch let error{
            object = nil
            print("JSONSerialization error: \(error.localizedDescription)")
        }
        if error != nil || object == nil || !(object is NSDictionary) {
            var userInfo = [
                NSLocalizedDescriptionKey: "Failed to parse JSON.",
                NSLocalizedFailureReasonErrorKey: "The data returned from the server does not meet the JSON syntax.",
                NSURLErrorKey: operation.response!.url!
            ] as [String : Any]
            if operation.error != nil {
                userInfo[NSUnderlyingErrorKey] = operation.error
            }
            let error = NSError(
                domain: website,
                code: 404,
                userInfo: userInfo)
          //  NSLog("\(operation.response!.URL!)\n\(error)\n\(NSString(data: data, encoding: NSUTF8StringEncoding)))")
            failure?(error)
            return
        }
       // print(object)
        let state = object?.object(forKey: "state") as! Int
        
        if state >= successCode {
            success?(JSON(data: (data as NSData) as Data))
            
            if  DataManager.defaultManager != nil {
                DataManager.defaultManager!.saveChanges()
            }
           
        } else if(state==tokenFailCode){
            appDelegate.LoginOut()
            //token失效，返回到登录界面重新登录
        }
        else{
            
            let msg = object?.object(forKey: "msg") as? String
            var userInfo = [
                //NSLocalizedDescriptionKey: getErrorState(state),
                NSLocalizedDescriptionKey: msg ?? getErrorState(state),
                NSURLErrorKey: operation.response!.url!
                
            ] as [String : Any]
            if operation.error != nil {
                userInfo[NSUnderlyingErrorKey] = operation.error
            }
            let error = NSError(
                domain: website,
                code: state,
                userInfo: userInfo)
            failure?(error)
        }
    }
    /**
     获取错误的中文描述
     
     - parameter state: 错误编码
     
     - returns: 中文描述信息
     */
    func getErrorState(_ state:Int)->String
    {
        var errorState=""
        if (self.ErrorCode.allKeys as! [String]).contains("\(state)")
        {
            errorState=self.ErrorCode["\(state)"] as! String
        }
        return errorState
    }
    /**
     清理cookies和当前用户信息
     */
    class func clearCookies() {
        let storage = HTTPCookieStorage.shared//as! [NSHTTPCookie]
        for cookie in (storage.cookies)! {
            storage.deleteCookie(cookie)
        }
        UserDefaults.standard.removeObject(forKey: UserDefaultsUserTokenKey)
        UserDefaults.standard.removeObject(forKey: UserDefaultsUserIDKey)
        UserDefaults.standard.synchronize()
        URLCache.shared.removeAllCachedResponses()
    }
    
    fileprivate let NetworkConfig: NSDictionary
    /// 接口前缀
    var website: String {
        
        return NetworkConfig["Website"] as! String // 正式服务器
      //  return NetworkConfig["Website2"] as! String // 测试服务器
    }
    /// 接口后缀路径地址
    var paths: [String: String] {
        return NetworkConfig["Path"] as! [String: String]
    }
    
    fileprivate lazy var manager: AFHTTPRequestOperationManager = {
        [weak self] in
        
        assert(self?.website != nil, "website不能为nil")
        let manager = AFHTTPRequestOperationManager(baseURL: Foundation.URL(string: (self?.website)!))
        manager.responseSerializer = AFHTTPResponseSerializer()
    //    manager.requestSerializer = AFHTTPRequestSerializer()
      //  manager.requestSerializer.timeoutInterval = 60
    
        // Https 证书设置
        let cerPath = Bundle.main.path(forResource: "https", ofType: "cer")
        if let c = cerPath{
            let cerData = NSData.init(contentsOfFile: cerPath!)
            let cerSet: [Any] =  Array.init(arrayLiteral: cerData ?? "")
            let securityPolicy = AFSecurityPolicy.init(pinningMode: AFSSLPinningMode.none)
            securityPolicy.allowInvalidCertificates = true // 是否允许无效的证书
            securityPolicy.pinnedCertificates = cerSet
            manager.securityPolicy = securityPolicy
        }
        
        return manager
        }()
    //用户的usertoken
    var userToken:String{
        if let tmptoken=UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey)
        {
            return (tmptoken as! String)
        }
        else{
            return ""
        }
        
    }
    
    /// 成功编码
    var successCode: Int {
        return Int((NetworkConfig["SuccessCode"] as! String))!
    }
    /// token失败的错误编码
    var tokenFailCode: Int {
        return Int((NetworkConfig["TokenFailCode"] as! String))!
    }
    /// 其他错误编码列表
    var ErrorCode: NSDictionary {
        return NetworkConfig["ErrorCode"] as! NSDictionary
    }
    //URL
    var URL: NSDictionary {
        return NetworkConfig["URL"] as! NSDictionary
    }
    
    var troubleHandle:NSDictionary{
        return NetworkConfig["TroubleHandle"]as! NSDictionary
    }
    
    func getTroubleHandle(_ state:String)->NSArray
    {
        let stateLong=(state as NSString).longLongValue
        let troubleHandle=NSMutableArray()
        if (self.troubleHandle.allKeys as! [String]).contains("\(stateLong)")
        {
            let state = "\(stateLong)"
            let dic = self.troubleHandle[state] as! NSDictionary
            if let arr = dic["New item"] as? NSArray
            {
                
                for item in arr{
                    troubleHandle.add(item)
                    
                }
            }
            
        }
        return troubleHandle
    }
    
}
