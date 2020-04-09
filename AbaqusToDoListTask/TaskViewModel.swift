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
    var taskResults : [Tasks]? = []
    
    
    func getUsers(completionHandler: @escaping (Bool) -> Void) {
        APIClient().fetchUsersList { (users) in
            DispatchQueue.main.async {
                self.taskResults = users
                 
//                for i in users! {
//                    let tskDic = [ "id" : i.id,
//                                   "task" : i.task,
//                                   "state" : i.state
//                        ] as [String : Any]
//                    self.taskResults?.append(tskDic)
//                    // CoreDataManager.shared.saveUserData(userModel: i)
//
//                }
           // let userDetails = CoreDataManager.shared.fetchUsers()
            //self.coreDataResults = userDetails
                //print("task : \(self.taskResults)")
                   
                completionHandler(true)
            }
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
       
        let dict : Tasks = filterArray(state: status)[indexPath.row] as! Tasks
        return dict.task
    }
    func getTaskStatus(for indexPath: IndexPath) -> Int {
        let dict = self.taskResults![indexPath.row]
        return dict.state
    }
}

