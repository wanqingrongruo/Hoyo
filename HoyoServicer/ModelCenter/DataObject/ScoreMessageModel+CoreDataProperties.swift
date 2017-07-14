//
//  ScoreMessageModel+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/20.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ScoreMessageModel {

    @NSManaged var createTime: String?
    @NSManaged var messageCon: String?
    @NSManaged var messageType: String?
    @NSManaged var msgId: String?
    @NSManaged var recvUserid: String?
    @NSManaged var sendImageUrl: String?
    @NSManaged var sendNickName: String?
    @NSManaged var sendUserid: String?
    @NSManaged var id: String?
    @NSManaged var remark: String?

}
