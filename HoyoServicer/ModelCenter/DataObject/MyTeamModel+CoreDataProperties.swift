//
//  MyTeamModel+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/12.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MyTeamModel {
    
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var createTime: String?
    @NSManaged var groupName: String?
    @NSManaged var groupNumber: String?
    @NSManaged var groupScopeName: String?
    @NSManaged var groupScoupValue: String?
    @NSManaged var headimageurl: String?
    @NSManaged var id: String?
    @NSManaged var memberState: String?
    @NSManaged var nickname: String?
    @NSManaged var province: String?
    @NSManaged var scopename: String?
    @NSManaged var scopevalue: String?
    @NSManaged var userself: String?
    @NSManaged var userselfNickname: String?
    @NSManaged var userselfCreateTime: String?
    @NSManaged var userselfMemberState: String?
    @NSManaged var suplevel1: String?
    @NSManaged var suplevel2:String?
    @NSManaged var suplevel3:String?
}
