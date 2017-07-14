//
//  FinishOrderModel.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 21/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class FinishOrderModel: NSObject {
    var orderid : String?
    var arrivetime:String?
    var usetime:String?
    var money:String?
    var machinetype:String?
    var machinecode:String?
    var PayWay:String?
    var Fault:String?
    var Remark:String?
    var productLists:[ProductInfo]?
}
