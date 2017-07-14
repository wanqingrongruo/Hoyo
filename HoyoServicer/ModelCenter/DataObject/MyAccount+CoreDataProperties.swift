//
//  MyAccount+CoreDataProperties.swift
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

extension MyAccount {

    @NSManaged var id: String?
    @NSManaged var balance: String?
    @NSManaged var income: String?
    @NSManaged var totalAssets: String?

}
