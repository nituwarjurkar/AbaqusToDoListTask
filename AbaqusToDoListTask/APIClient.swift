//
//  APIClient.swift
//  AbaqusToDoListTask
//
//  Created by Nitu Warjurkar on 08/04/20.
//  Copyright © 2020 Ecsion Research Labs Pvt. Ltd. All rights reserved.
//
import Foundation
class APIClient: NSObject {
    
    func fetchUsersList(completion: @escaping ([Tasks]?) -> Void) {
        
        guard let url = URL(string:"https://my-json-server.typicode.com/karthikraj-duraisamy/todoendpoint/tasks") else {
            print("Error unwrapping URL")
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard let unwrappedData = data else {
                print("Error getting data")
                return
            }
            do {
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode([Tasks].self, from: unwrappedData)
                    print(result)
                    completion(result)
                } catch { print(error) }
                
            }
        }
        dataTask.resume()
    }
}

