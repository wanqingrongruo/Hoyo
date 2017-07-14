//
//  AccountDetailModel+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/9.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension AccountDetailModel {

    @NSManaged var id: String?
    @NSManaged var userId: String?
    @NSManaged var payId: String?
    @NSManaged var money: String?
    @NSManaged var way: String?
    @NSManaged var remark: String?
    @NSManaged var createTime: String?

}
