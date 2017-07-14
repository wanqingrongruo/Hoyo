//
//  RNPayOrderModel.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/9/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNPayOrderModel: NSObject {
    
    var orderId: String?
    var orderName: String?
    var payMoney: Float? // 以分为单位
    
    var payInfos: [RNPAYDetailModel]? // 费用明细

}
