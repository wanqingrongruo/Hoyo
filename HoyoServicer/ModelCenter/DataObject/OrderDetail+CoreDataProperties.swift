//
//  OrderDetail+CoreDataProperties.swift
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

extension OrderDetail {
    
    @NSManaged var address: String?
    @NSManaged var addressDetail: String?
    @NSManaged var checkState: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var distance: String?
    @NSManaged var enginerImage: String?
    @NSManaged var id: String?
    @NSManaged var imageDetail: String?
    @NSManaged var lat: String?
    @NSManaged var lng: String?
    @NSManaged var mobile: String?
    @NSManaged var nickname: String?
    
    @NSManaged var productName: String?
    @NSManaged var productModel: String?
    @NSManaged var productBrand: String?
    
    @NSManaged var province: String?
    @NSManaged var topImage: String?
    @NSManaged var troubleDescripe: String?
    @NSManaged var troubleHandleType: String?
    @NSManaged var userImage: String?
    @NSManaged var visitTime: String?
    @NSManaged var aimAdress: String?
    @NSManaged var orderId: String?
    
    @NSManaged var telephoneNumber: String?
    
    @NSManaged var crmID: String?
    
    @NSManaged var hoyoID: String?
    
    @NSManaged var areaCode: String?
    
    @NSManaged var clientName: String?
    @NSManaged var expressCode: String?
    
    @NSManaged var deviceType: String?
}
