//
//  Settlementinfo.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 13/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class Settlementinfo: NSObject {
//提成金额
    var money :String?
    //扣款金额
    var debitMoney :String?
    //上级提成
    var  higherMoney :String?
    //结算时间
    var  settleTime :String?
    
    //扣款备注
    var remark : String?
}
