//
//  UserIdentifier+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/19.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import Foundation
import CoreData


extension UserIdentifier {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserIdentifier> {
        return NSFetchRequest<UserIdentifier>(entityName: "UserIdentifier")
    }

    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var groupId: String?
    @NSManaged public var identifier: String?
    @NSManaged public var scope: String?
    @NSManaged public var state: String?
}
