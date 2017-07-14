//
//  RNUserRecordModel.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/21.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class RNUserRecordModel: NSObject {

    var id: Int?
    var deviceId: String?
    var filterId: String?
    var name: String?
    var year: String?
    var isRealData: Bool?  // 用这个标识是不是从后台获取的真是数据
    var index: Int?
}
