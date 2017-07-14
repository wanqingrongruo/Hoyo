//
//  User+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by zhuguangyang on 16/7/11.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var bannerimgs: String?
    @NSManaged var bdimgs: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var groupdetails: Data?
    @NSManaged var headimageurl: String?
    @NSManaged var id: String?
    @NSManaged var language: String?
    @NSManaged var lat: NSNumber?
    @NSManaged var lng: NSNumber?
    @NSManaged var mobile: String?
    @NSManaged var name: String?
    @NSManaged var openid: String?
    @NSManaged var orderabout: Data?
    @NSManaged var province: String?
    @NSManaged var realname: Data?
    @NSManaged var scope: String?
    @NSManaged var score: String?
    @NSManaged var sex: String?
    @NSManaged var usertoken: String?

}
