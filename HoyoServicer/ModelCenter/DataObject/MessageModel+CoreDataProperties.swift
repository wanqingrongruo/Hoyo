//
//  MessageModel+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/17.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MessageModel {

    @NSManaged var msgId: String?
    @NSManaged var sendUserid: String?
    @NSManaged var recvUserid: String?
    @NSManaged var sendNickName: String?
    @NSManaged var sendImageUrl: String?
    @NSManaged var messageCon: String?
    @NSManaged var messageType: String?
    @NSManaged var createTime: String?
    @NSManaged var id: String?
    @NSManaged var messageNum:String?

}
