//
//  CoreDataManager.swift
//  AbaqusToDoListTask
//
//  Created by Nitu Warjurkar on 09/04/20.
//  Copyright © 2020 Ecsion Research Labs Pvt. Ltd. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
        let TaskDataEntity = "Tasks"
    
        private let backgroundContextName = "backgroundContext"
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AbaqusToDoListTask")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // iOS 9 and below
        lazy var applicationDocumentsDirectory: URL = {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls[urls.count-1]
        }()
        
        lazy var managedObjectModel: NSManagedObjectModel = {
            // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
            let modelURL = Bundle.main.url(forResource: "AbaqusToDoListTask", withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()
        
        lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
            // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
            // Create the coordinator and store
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("CoreData.sqlite")
            print("sqlite Url: \(url)")
            var failureReason = "There was an error creating or loading the application's saved data."
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
                dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
                
                dict[NSUnderlyingErrorKey] = error as NSError
                let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                abort()
            }
            
            return coordinator
        }()
        
        lazy var mainContext: NSManagedObjectContext = {
            // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.undoManager = nil
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            context.persistentStoreCoordinator = persistentStoreCoordinator
            
    //        NotificationCenter.default.addObserver(self, selector: #selector(CoreDataManager.mainContextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)

            return context
        }()
        
        lazy var backgroundContext: NSManagedObjectContext = {
    //    @objc public func newBackgroundContext() -> NSManagedObjectContext {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.name = backgroundContextName
            context.persistentStoreCoordinator = persistentStoreCoordinator
            context.undoManager = nil
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            
            NotificationCenter.default.addObserver(self, selector: #selector(CoreDataManager.backgroundContextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
            
            return context
        }()
        
        // Can't be private, has to be internal in order to be used as a selector.
        @objc func backgroundContextDidSave(_ notification: Notification) throws {
            let context = notification.object as? NSManagedObjectContext
            guard context?.name == backgroundContextName else {
                return
            }
            
            if Thread.isMainThread == false {
                throw NSError(domain: "Background context saved in the main thread. Use context's `performBlock`", code: 1, userInfo: nil)
            } else {
                let contextBlock: @convention(block) () -> Void = {
                    self.mainContext.mergeChanges(fromContextDidSave: notification)
                }
                let blockObject: AnyObject = unsafeBitCast(contextBlock, to: AnyObject.self)
                self.mainContext.perform(CoreDataManager.performSelectorForBackgroundContext(), with: blockObject)
            }
        }
        
        private static func performSelectorForBackgroundContext() -> Selector {
            return NSSelectorFromString("performBlock:")
        }
    // MARK: - Core Data Saving support
    
    fileprivate func getMainContext() -> NSManagedObjectContext  {
        return mainContext
        /*
        if #available(iOS 10.0, *) {
            return persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            return mainContext
        }
        */
    }
    
    fileprivate func getBackgroundContext() -> NSManagedObjectContext  {
        return backgroundContext
        /*
        if #available(iOS 10.0, *) {
            return persistentContainer.newBackgroundContext()
        } else {
            // Fallback on earlier versions
            return backgroundContext
        }
        */
    }
    
    func saveTaskData(taskModel: TasksModel) {
        let context = getMainContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TaskDataEntity)
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "(id == '\(taskModel.id)')")
        do {
            let result = try context.fetch(request)
            if result.isEmpty {
                 //insert new peripheral
                let entity = NSEntityDescription.entity(forEntityName: TaskDataEntity, in: context)
                let taskData = Tasks(entity: entity!, insertInto: context)
                taskData.id = Int16(taskModel.id)
                taskData.task = taskModel.task
                taskData.state = Int16(taskModel.state)
        
            } else {
                // update peripheral
                let taskData = result.first! as! Tasks
                taskData.id = Int16(taskModel.id)
                taskData.task = taskModel.task
                taskData.state = Int16(taskModel.state)
            }
        } catch _ as NSError {
            print("Error")
        }
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                    print("Saved")
                } catch {
                    print("Error")
                }
            }
        }
    }
    
    func deleteAllPeripherals() {
           let context = getMainContext()
           // Create Fetch Request
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TaskDataEntity)
          //fetchRequest.predicate = NSPredicate(format: "(id == '\(taskModel.id)')")
        
           // Create Batch Delete Request
           let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
           do {
               try context.execute(batchDeleteRequest)
           } catch {
               // Error Handling
               print("Error")
           }
       }
       func deleteTasks(taskIdArray: [Int]) {
                 let context = getMainContext()
                for id in taskIdArray {
                    // Create Fetch Request
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TaskDataEntity)
                    fetchRequest.predicate = NSPredicate(format: "(id == '\(id)')")
                    // Create Batch Delete Request
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    do {
                        try context.execute(batchDeleteRequest)
                    } catch {
                        // Error Handling
                        print("Error")
                    }
        }
                 
             }
       func fetchTasks() -> [TasksModel]? {
           let context = getMainContext()
           var taskData = [TasksModel]()
           let request = NSFetchRequest<Tasks>(entityName: TaskDataEntity)
           request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
           do {
               let taskValue = try context.fetch(request)
               for (_, user) in taskValue.enumerated() {
                let task: TasksModel = TasksModel(id: Int(user.id), task: user.task ?? "", state: Int(user.state))
                taskData.append(task)
               }
               return taskData
           } catch {
           }
           return nil
       }
    func fetchLastId() -> Int {
        let context = getMainContext()
         
        let request = NSFetchRequest<Tasks>(entityName: TaskDataEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]

        do {
            let taskValue = try context.fetch(request)
            var recordID = 1
            if let lastRecordID = taskValue.first?.id {
                recordID = Int(lastRecordID) + 1
            }
            return recordID
        } catch {
        }
        return 1
    }
       
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
