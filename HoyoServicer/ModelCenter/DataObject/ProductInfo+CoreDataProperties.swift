//
//  ProductInfo+CoreDataProperties.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/12/22.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
import CoreData


extension ProductInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductInfo> {
        return NSFetchRequest<ProductInfo>(entityName: "ProductInfo");
    }

    @NSManaged public var company: String?
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var numbers: NSNumber?
    @NSManaged public var price: String?
    @NSManaged public var pjCode: String?
    @NSManaged public var productType: String?
    @NSManaged public var productsID: String?
    @NSManaged public var dw: String?
    @NSManaged public var pjNO: String?
    @NSManaged public var chCount: NSNumber?
    @NSManaged public var hsCount: NSNumber?
    @NSManaged public var k3PJ: String?

}
