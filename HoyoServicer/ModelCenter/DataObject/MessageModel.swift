//
//  MessageModel.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/17.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
import CoreData


class MessageModel: DataObject {
    
    /**
     单个未读消息条数
     */
    class func updateSource(_ newModel: String,entityName: String) -> String{
        
        var strNum: String = "0"
        let entity = NSEntityDescription.entity(forEntityName: "MessageModel", in: DataManager.defaultManager.managedObjectContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        
        let arr:[MessageModel] = try! DataManager.defaultManager.managedObjectContext.fetch(request) as! [MessageModel]
        
        for item in arr {
            if item.sendUserid == newModel{
                strNum = item.messageNum ?? "0"
                DataManager.defaultManager.managedObjectContext.delete(item)
            }
        }
        do{
            try DataManager.defaultManager.managedObjectContext.save()
        } catch {
            print(error)
        }
        return strNum
    }
    
    /**
     总未读消息条数
     - returns:
     */
    class func userMessageNum(_ newModel: String,entityName: String) -> String{
        
        var strNum: String = "0"
        let entity = NSEntityDescription.entity(forEntityName: "MessageModel", in: DataManager.defaultManager.managedObjectContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        
        let arr:[MessageModel] = try! DataManager.defaultManager.managedObjectContext.fetch(request) as! [MessageModel]
        
        for item in arr {
            if item.sendUserid == newModel{
                strNum = item.messageNum ?? "0"
            }
        }
        return strNum
    }
    
    /**
     更新某个联系人消息未读条数为0
     - parameter newModel:
     - parameter entityName:
     */
    class func updateSourceMessageNum(_ newModel: String,entityName: String) {
        
        //        var strNum: String = "0"
        let entity = NSEntityDescription.entity(forEntityName: "MessageModel", in: DataManager.defaultManager.managedObjectContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        
        let arr:[MessageModel] = try! DataManager.defaultManager.managedObjectContext.fetch(request) as! [MessageModel]
        
        for item in arr {
            if item.sendUserid == newModel{
                item.messageNum = "0"
                //                appDelegate.managedObjectContext.deleteObject(item)
            }
        }
        do{
            try DataManager.defaultManager.managedObjectContext.save()
        } catch {
            print(error)
        }
    }

    
    /*
     // Insert code here to add functionality to your managed object subclass
     class func updateSource(newModel: String,entityName: String) {
     
     let entity = NSEntityDescription.entityForName("MessageModel", inManagedObjectContext: DataManager.defaultManager.managedObjectContext)
     
     let request = NSFetchRequest()
     request.entity = entity
     
     let arr:[MessageModel] = try! DataManager.defaultManager.managedObjectContext.executeFetchRequest(request) as! [MessageModel]
     
     for item in arr {
     if item.sendUserid == newModel{
     DataManager.defaultManager.managedObjectContext.deleteObject(item)
     }
     }
     DataManager.defaultManager.saveChanges()
     
     }
     */
    class func deleteSource(_ newModel: String,entityName: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "MessageModel", in: DataManager.defaultManager.managedObjectContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        
        let arr:[MessageModel] = try! DataManager.defaultManager.managedObjectContext.fetch(request) as! [MessageModel]
        
        for item in arr {
            if item.sendUserid == newModel{
                DataManager.defaultManager.managedObjectContext.delete(item)
            }
        }
        DataManager.defaultManager.saveChanges()
        
    }
    
}
