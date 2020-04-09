//
//  TaskViewModel.swift
//  AbaqusToDoListTask
//
//  Created by Nitu Warjurkar on 08/04/20.
//  Copyright © 2020 Ecsion Research Labs Pvt. Ltd. All rights reserved.
//

import Foundation
class ViewModel: NSObject {
   //var apiClient: APIClient!
    var taskResults : [TasksModel]? = []
    
    
    func getTasks(completionHandler: @escaping (Bool) -> Void) {
        APIClient().fetchUsersList { (tasks) in
            DispatchQueue.main.async {
                self.taskResults = tasks
                 
                for task in tasks! {
                     CoreDataManager.shared.saveTaskData(taskModel: task)
                }
            let taskDetails = CoreDataManager.shared.fetchTasks()
            self.taskResults = taskDetails
            
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
    func numberOfTaskToDisplay(in section: Int) -> Int {
         
        return filterArray(state: section).count
    }
    func filterArray(state: Int) -> Array<Any> {
          let filteredItems = taskResults?.filter { $0.state == state }
        return filteredItems ?? []
    }
    func getTaskId(in indexPath: IndexPath) -> Int {
        let dict = self.taskResults?[indexPath.row]
        return dict?.id ?? 0
      
    }
    func getTaskName(for indexPath: IndexPath, status: Int) -> String {
       
        let dict : TasksModel = filterArray(state: status)[indexPath.row] as! TasksModel
        return dict.task
    }
    func getTaskStatus(for indexPath: IndexPath) -> Int {
        let dict = self.taskResults![indexPath.row]
        return dict.state
    }
}

