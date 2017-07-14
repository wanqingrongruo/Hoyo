//
//  FinshDetail+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 13/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//
//------------不是存储的-----就是简单模型
import Foundation
import CoreData

class  FinshDetail :NSObject {
    
    var arrivetime: String?
    var machineCode: String?
    var machineType: String?
    var money: String?
    var payWay: String?
    var reason: String?
    var remark: String?
    var troubleDetail: String?
    var usetime: String?
    var orderId: String?
    var photos: Array<String>?
}
