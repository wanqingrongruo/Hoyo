//
//  DataManager.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/10/7.
//  Copyright (c) 2015年 BetaTech. All rights reserved.
//

import CoreData
import Foundation

class DataManager: NSObject {
    fileprivate static var _defaultManager: DataManager! = nil
    
    static var defaultManager: DataManager! {
        get {
            if _defaultManager == nil {
                _defaultManager = DataManager()
            }
            return _defaultManager
        }
        set {
            _defaultManager = newValue
        }
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ozner.HoyoServicer" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "HoyoServicer", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let sqlName = ((UserDefaults.standard.object(forKey: UserDefaultsUserIDKey) ?? "DefaultCoreData") as! String)+".sqlite"
        print("数据库文件名是:"+sqlName)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(sqlName)
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            //dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveChanges () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    func create(_ entityName: String) -> DataObject {
        let entity = managedObjectModel.entitiesByName[entityName]!
        return DataObject(entity: entity, insertInto: managedObjectContext)
    }
    func fetch(_ entityName: String, ID: NSString, error: NSErrorPointer) -> DataObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "id = %@", ID)
        request.fetchLimit = 1
        var results:[AnyObject]?   
        do {
            results = try managedObjectContext.fetch(request)
        } catch {
            print("无")
        }
        
        if results != nil && results!.count != 0 {
            return results![0] as? DataObject
        } else {
//            if error != nil && error??.pointee == nil {
//                error??.pointee = NSError(domain: "", code: 0, userInfo: nil) // Needs specification
//            }
            
            if  error?.pointee == nil {
                error?.pointee = NSError(domain: "", code: 0, userInfo: nil) // Needs specification
            }
            return nil
        }
    }
    func fetchAll(_ entityName: String, error: NSErrorPointer) -> [DataObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let results = try? managedObjectContext.fetch(request)
        if results != nil {
            return results as! [DataObject]
        } else {
//            if error != nil && error??.pointee == nil {
//                error??.pointee = NSError(domain: "", code: 0, userInfo: nil) // Needs specification
//            }
            if  error?.pointee == nil {
                error?.pointee = NSError(domain: "", code: 0, userInfo: nil) // Needs specification
            }
            return []
        }
    }
    func autoGenerate(_ entityName: String, ID: NSString) -> DataObject {
        var object = fetch(entityName, ID: ID, error: nil)
        if object == nil {
            object = create(entityName)
            object!.setValue(ID, forKey: "id")
        }
        return object!
    }
    func deleteObjectsWithIDs(_ entityName: String,IDArray:[NSString]) {
        var error: NSError?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(value: true)
        let results = try? managedObjectContext.fetch(request)
        if results != nil {
            for r in results! {
                if IDArray.contains((r as! NSManagedObject).value(forKey: "id")  as! NSString)
                {
                    managedObjectContext.delete(r as! NSManagedObject)
                }
            }
        } else {
            if error != nil {
                error = NSError(domain: "删除表\(entityName)中数据错误", code: 0, userInfo: nil)
                print(error ?? "")
            }
        }
        
    }
    func deleteAllObjectsWithEntityName(_ entityName: String) {
        var error: NSError?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(value: true)
        let results = try? managedObjectContext.fetch(request)
        if results != nil {
            for r in results! {
                managedObjectContext.delete(r as! NSManagedObject)
            }
        } else {
            if error != nil {
                error = NSError(domain: "清空表\(entityName)错误", code: 0, userInfo: nil)
                print(error ?? "")
            }
        }
        
    }

}
