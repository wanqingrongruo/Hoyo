//
//  DataObject.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/3/28.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
import CoreData


class DataObject: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    fileprivate class func cast<T>(_ object: NSManagedObject, type: T.Type) -> T {
        return object as! T
    }
    //通过ID查找
    class func cachedObjectWithID(_ ID: NSString) -> Self {
      //  print(entityName)
        return cast(DataManager.defaultManager!.autoGenerate(entityName, ID: ID), type: self)
    }
    //查找此表的全部数据
    class func allCachedObjects() -> [DataObject] /* [Self] in not supported. */ {
        return DataManager.defaultManager!.fetchAll(entityName, error: nil)
        
    }
    //通过id删除数据
    class func deleteCachedObjectsWithID(_ IDArray:[NSString]) {
        DataManager.defaultManager!.deleteObjectsWithIDs(entityName, IDArray: IDArray)
    }
    //删除此表全部数据
    class func deleteAllCachedObjects() {
        DataManager.defaultManager!.deleteAllObjectsWithEntityName(entityName)
    }
    
//    class func temporaryObject() -> Self {
//        return cast(DataManager.temporaryManager!.create(entityName), type: self)
//    }
    
    class var entityName: String {
        
        let s:String = NSStringFromClass(self)
        return s.components(separatedBy: ".").last ?? s
    }
}
