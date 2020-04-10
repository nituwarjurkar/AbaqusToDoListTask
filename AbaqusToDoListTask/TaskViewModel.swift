//
//  TaskViewModel.swift
//  AbaqusToDoListTask
//
//  Created by Nitu Warjurkar on 08/04/20.
//  Copyright © 2020 Ecsion Research Labs Pvt. Ltd. All rights reserved.
//

import Foundation

class ViewModel: NSObject {
    
    var taskResults : [TasksModel]? = []
    
    func getTasks(completionHandler: @escaping (Bool) -> Void) {
        
        APIClient().fetchUsersList { (tasks) in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "isAppFirstTimeLaunched")
                self.taskResults = tasks
                for task in tasks! {
                    CoreDataManager.shared.saveTaskData(taskModel: task)
                }
                completionHandler(true)
            }
        }
    }
    
    func reloadTasks(completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            
            let taskDetails = CoreDataManager.shared.fetchTasks()
            self.taskResults = taskDetails
            
            completionHandler(true)
        }
    }
     
    func filterArray(state: Int) -> [TasksModel] {
        let filteredItems = taskResults?.filter { $0.state == state }
        return filteredItems ?? []
    }
    
    
}

