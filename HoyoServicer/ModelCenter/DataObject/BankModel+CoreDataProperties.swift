//
//  BankModel+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 16/5/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BankModel {

    @NSManaged var bankLogo: String?
    @NSManaged var bankName: String?
    @NSManaged var bankType: String?
    @NSManaged var bindTime: String?
    @NSManaged var cardId: String?
    @NSManaged var cardPhone: String?
    @NSManaged var id: String?
    @NSManaged var userName: String?
    @NSManaged var bankId: String?
    @NSManaged var bankBranch: String?
}
