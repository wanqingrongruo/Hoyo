//
//  commonAttribute.swift
//  OznerServer
//
//  Created by 赵兵 on 16/2/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
//状态栏高度
let HEIGHT_StatusBar:CGFloat=20
//导航栏高度
let HEIGHT_NavBar:CGFloat=64
//导航栏高度
let HEIGHT_TabBar:CGFloat=49
//当前屏幕bounds
let MainScreenBounds = UIScreen.main.bounds
//获取当前屏幕 宽度、高度
let WIDTH_SCREEN:CGFloat = UIScreen.main.bounds.size.width
let HEIGHT_SCREEN:CGFloat = UIScreen.main.bounds.size.height
//参考的设计图纸尺寸
let WidthOfDesign:CGFloat=375.0
let HeightOfDesign:CGFloat=667.0
//消息通知
let messageNotification = "MessageNotification"
let scoreNotification = "ScoreNotification"
let  OrderPushNotification = "HomeOrderNotification"
let OrderPushNotificationString = "NewMessageNotification"


//宽比例尺寸换算
func WidthFromTranslat(_ width:CGFloat)->CGFloat
{
    return width*WIDTH_SCREEN/WidthOfDesign
}
//高比例尺寸换算
func HeightFromTranslat(_ height:CGFloat)->CGFloat
{
    return height*HEIGHT_SCREEN/HeightOfDesign
}
//系统版本号
let IOS_VERSION:Float = Float((UIDevice.current.systemVersion as NSString).substring(to: 1))!


// 位置
let PROVINCE = "Province" // 省
let CITY = "City" //城市
let LATITUDE = "latitude" // 纬度
let LONGITUDE = "longitude" // 经度

// 当前位置 - 用于提交订单时提交工程师位置
let CURRENTPROVINCE = "CurrentProvince" // 省
let CURRENTCITY = "CurrentCity" //城市
let CURRENTLATITUDE = "CurrentLatitude" // 纬度
let CURRENTLONGITUDE = "CurrentLongitude" // 经度

// 服务器地址
let SERVICEADDRESS = "http://wechat.hoyofuwu.com" // 正式环境
//let SERVICEADDRESS = "http://192.168.173.22" // 测试环境
