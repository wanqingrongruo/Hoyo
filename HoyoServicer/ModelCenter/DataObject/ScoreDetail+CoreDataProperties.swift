//
//  ScoreDetail+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 29/4/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ScoreDetail {

    @NSManaged var createTime: String?
    @NSManaged var id: String?
    @NSManaged var orderId: String?
    @NSManaged var remark: String?
    @NSManaged var score: String?
    @NSManaged var userid: String?
    @NSManaged var headimageurl: String?

}
