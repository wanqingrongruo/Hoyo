//
//  NSDate+expand.swift
//  OznerServer
//
//  Created by 赵兵 on 16/2/26.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
///日期操作类
class DateTool
{
    /**
     服务器时间戳转换成ios日期格式：例如："\Date(121300032190)\"->NSDate
     
     - parameter TimeStamp: "\Date(121300032190)\"
     
     - returns: NSDate
     */
    class func dateFromServiceTimeStamp(_ TimeStamp:String)->Date? {
        if  MSRIsNilOrNull(TimeStamp as AnyObject?) || TimeStamp.characters.count<10
        {
            return Date()
        }
        var tmpStr=TimeStamp as NSString
        tmpStr=tmpStr.substring(from: 6) as NSString
        tmpStr=tmpStr.substring(to: tmpStr.length-2) as NSString
        let tmpTimeStr=TimeInterval(tmpStr.longLongValue/1000)
        return Date(timeIntervalSince1970: tmpTimeStr)
    }
    /**
     服务器时间戳转换成ios时间戳：例如："\Date(121300032190)\"->121300032
     
     - parameter TimeStamp: "\Date(121300032190)\"
     Interval
     - returns: NSTimeInterval
     */
    class func TimeIntervalFromServiceTimeStamp(_ TimeStamp:String)->TimeInterval? {
        if  MSRIsNilOrNull(TimeStamp as AnyObject?) || TimeStamp.characters.count<10
        {
            return Date().timeIntervalSince1970
        }
        var tmpStr=TimeStamp as NSString
        
        tmpStr=tmpStr.substring(from: 6) as NSString
        tmpStr=tmpStr.substring(to: tmpStr.length-2) as NSString
        let tmpTimeStr=TimeInterval(tmpStr.intValue/1000)
        return tmpTimeStr
    }
    
    class func stringFromDate(_ date:Date,dateFormat:String)->String {
        let tmpDate=DateFormatter()
        tmpDate.dateFormat=dateFormat
        return tmpDate.string(from: date)
    }
    
    class func dateFromString(_ dateString:String,dateFormat:String)->Date {
        let tmpDate=DateFormatter()
        tmpDate.dateFormat=dateFormat
        return tmpDate.date(from: dateString)!
    }
    
    /**
     日期转化为星期
     
     - parameter date: iOS日期
     
     - returns: 星期时间
     */
    class func dayOfweek(_ date: Date) -> String {
        let interval = date.timeIntervalSince1970
        let days = Int(interval/86400)
        let day = (days - 3) % 7
        switch day {
        case 0:
            return "星期日"
        case 1:
            return "星期一"
        case 2:
            return "星期二"
        case 3:
            return "星期三"
        case 4:
            return "星期四"
        case 5:
            return "星期五"
        case 6:
            return "星期六"
        default :
            break
            
        }
        return " "
    }
    
}
