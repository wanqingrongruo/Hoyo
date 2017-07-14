//
//  RNAplipayModel.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/9/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNAlipayModel: NSObject {
    
    // NOTE: 支付宝分配给开发者的应用ID(如2014072300007148)
    var app_id: String?
    
    // NOTE: 支付接口名称
    var methods: String?
    
    // NOTE: (非必填项)仅支持JSON
    var format: String?
    
    // NOTE: (非必填项)HTTP/HTTPS开头字符串
    var return_url: String?
    
    // NOTE: 参数编码格式，如utf-8,gbk,gb2312等
    var charset: String?
    
    // NOTE: 请求发送的时间，格式"yyyy-MM-dd HH:mm:ss"
    var timestamp: String?
    
    // NOTE: 请求调用的接口版本，固定为：1.0
    var version: String?
    
    // NOTE: (非必填项)支付宝服务器主动通知商户服务器里指定的页面http路径
    var notify_url: String?
    
    // NOTE: (非必填项)商户授权令牌，通过该令牌来帮助商户发起请求，完成业务(如201510BBaabdb44d8fd04607abf8d5931ec75D84)
    var app_auth_token: String?
    
    // NOTE: 具体业务请求数据
    var biz_content: BizContent?
    
    // NOTE: 签名类型
    var sign_type: String?
    
   

}
//
//class BizContent: NSObject {
//    // NOTE: (非必填项)商品描述
//    var body: String?
//    
//    // NOTE: 商品的标题/交易标题/订单标题/订单关键字等。
//    var subject: String?
//    
//    // NOTE: 商户网站唯一订单号
//    var out_trade_no: String?
//    
//    // NOTE: 该笔订单允许的最晚付款时间，逾期将关闭交易。
//    //       取值范围：1m～15d m-分钟，h-小时，d-天，1c-当天(1c-当天的情况下，无论交易何时创建，都在0点关闭)
//    //       该参数数值不接受小数点， 如1.5h，可转换为90m。
//    var timeout_express: String?
//    
//    // NOTE: 订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]
//    var total_amount: String?
//    
//    // NOTE: 收款支付宝用户ID。 如果该值为空，则默认为商户签约账号对应的支付宝用户ID (如 2088102147948060)
//    var seller_id: String?
//    
//    // NOTE: 销售产品码，商家和支付宝签约的产品码 (如 QUICK_MSECURITY_PAY)
//    var product_code: String?
//    
//    
//    func descriptionAction() -> String{
//        
//        var tmpDic = [String: String]()
//        
//        tmpDic["subject"] =  subject ?? ""
//        tmpDic["out_trade_no"] =  out_trade_no ?? ""
//        tmpDic["total_amount"] = total_amount ?? ""
//        tmpDic["seller_id"] = seller_id ?? ""
//        tmpDic["product_code"] = product_code ?? "QUICK_MSECURITY_PAY"
//        
//        if body != nil && body != "" {
//            tmpDic["body"] = body!
//        }
//        
//        if timeout_express != nil && timeout_express != "" {
//            tmpDic["timeout_express"] = timeout_express!
//        }
//        
//        let tmpData =  try! NSJSONSerialization.dataWithJSONObject(tmpDic, options: NSJSONWritingOptions.init(rawValue: 0))
//        let tmpStr  = String(data: tmpData, encoding: NSUTF8StringEncoding)
//        
//        return tmpStr!
//    }
//
//}