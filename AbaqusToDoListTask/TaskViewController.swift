//
//  TaskViewController.swift
//  AbaqusToDoListTask
//
//  Created by Nitu Warjurkar on 08/04/20.
//  Copyright © 2020 Ecsion Research Labs Pvt. Ltd. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
     @IBOutlet var viewModel: ViewModel!
    @IBOutlet weak var taskSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var addTaskBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
         
        initViewModel()
         
    }
    func initViewModel(){
       viewModel?.getTasks(completionHandler: { (result) in
                   DispatchQueue.main.async {
                       if result {
                         //  self.loader.hideOverlayView()
                           self.tableView.reloadData()
                       }
                   }
               })
    }
    
    @IBAction func AddTaskClicked(_ sender: UIBarButtonItem) {
        createNewTask()
    }
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    func createNewTask() {
        let alertController = UIAlertController(title: "Add New Task", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Task Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.insertTaskinDB(taskName: firstTextField.text ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
       

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    func insertTaskinDB(taskName: String) {
        let lastId = CoreDataManager.shared.fetchLastId()
        print(lastId)
        let taskModel = TasksModel(id: lastId, task: taskName, state: 0)
        CoreDataManager.shared.saveTaskData(taskModel: taskModel)
        viewModel?.reloadTasks(completionHandler: { (result) in
                          DispatchQueue.main.async {
                              if result {
                                //  self.loader.hideOverlayView()
                                  self.tableView.reloadData()
                              }
                          }
                      })
    }

}
extension TaskViewController : UITableViewDelegate, UITableViewDataSource {
   // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var returnValue = 0
        
        switch(taskSegmentControl.selectedSegmentIndex)
        {
        case 0:
            returnValue = viewModel.numberOfTaskToDisplay(in: taskSegmentControl.selectedSegmentIndex)
            break
        case 1:
            returnValue = viewModel.numberOfTaskToDisplay(in: taskSegmentControl.selectedSegmentIndex) 
            break
            
        default:
            break
            
        }
        
        return returnValue
       
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 137.0
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell

        switch(taskSegmentControl.selectedSegmentIndex)
        {
        case 0:
            cell.textLabel!.text = viewModel?.getTaskName(for: indexPath, status: taskSegmentControl.selectedSegmentIndex)
            break
        case 1:
            cell.textLabel!.text = viewModel?.getTaskName(for: indexPath, status: taskSegmentControl.selectedSegmentIndex)
            break
        default:
            break
            
        }

        return cell
    }
 
}
