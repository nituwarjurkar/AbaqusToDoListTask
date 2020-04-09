//
//  Tasks.swift
//  AbaqusToDoListTask
//
//  Created by Nitu Warjurkar on 08/04/20.
//  Copyright © 2020 Ecsion Research Labs Pvt. Ltd. All rights reserved.

//

struct TasksModel : Decodable {
    
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case task = "task"
        case state = "state"
    }
    
    let id : Int
    let task : String
    let state : Int
   
}
