//
//  ScoreMessageModel.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/20.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import Foundation
import CoreData


class ScoreMessageModel: DataObject {
    
    // Insert code here to add functionality to your managed object subclass
    class func GetSourceArr(_ newModel: String,entityName: String)  ->  [ScoreMessageModel]{
        var scoreArr: [ScoreMessageModel]  = []
        
        let entity = NSEntityDescription.entity(forEntityName: "ScoreMessageModel", in:  DataManager.defaultManager.managedObjectContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        
        let arr:[ScoreMessageModel] = try! DataManager.defaultManager.managedObjectContext.fetch(request) as! [ScoreMessageModel]
        for item in arr {
            print(item.sendUserid ?? "")
            if item.sendUserid == newModel{
                scoreArr.append(item)
            }
        }
        
        return scoreArr
    }
    
    class func deleteSource(_ newModel: String,entityName: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "ScoreMessageModel", in: DataManager.defaultManager.managedObjectContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        
        let arr:[ScoreMessageModel] = try! DataManager.defaultManager.managedObjectContext.fetch(request) as! [ScoreMessageModel]
        
        for item in arr {
            if item.sendUserid == newModel{
                DataManager.defaultManager.managedObjectContext.delete(item)
            }
        }
        DataManager.defaultManager.saveChanges()
//        do{
//            try DataManager.defaultManager.managedObjectContext.save()
//        } catch {
//            print(error)
//        }
        
    }
    
    class func deleteSourceOne(_ newModel: String,entityName: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "ScoreMessageModel", in: DataManager.defaultManager.managedObjectContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        
        let arr:[ScoreMessageModel] = try! DataManager.defaultManager.managedObjectContext.fetch(request) as! [ScoreMessageModel]
        
        for item in arr {
            if item.msgId == newModel{
                DataManager.defaultManager.managedObjectContext.delete(item)
            }
        }
        DataManager.defaultManager.saveChanges()
        //        do{
        //            try DataManager.defaultManager.managedObjectContext.save()
        //        } catch {
        //            print(error)
        //        }
        
    }
    
    
}
