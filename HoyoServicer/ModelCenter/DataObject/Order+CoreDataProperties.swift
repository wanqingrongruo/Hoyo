//
//  Order+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by 杨龙洲 on 12/6/16.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Order {

    @NSManaged var address: String?
    @NSManaged var checkState: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var createTime: String?
    @NSManaged var describe: String?
    @NSManaged var distance: String?
    @NSManaged var headimageurl: String?
    @NSManaged var id: String?
    @NSManaged var modifyTime: String?
    @NSManaged var productModel: String?
    @NSManaged var productName: String?
    @NSManaged var province: String?
    @NSManaged var serviceItem: String?
    @NSManaged var lng: NSNumber?
    @NSManaged var lat: NSNumber?
    @NSManaged var appointmentTime: String?
    
    @NSManaged var orderId: String?
}
