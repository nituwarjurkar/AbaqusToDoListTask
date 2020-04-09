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
    var taskIdArray : [Int] = []
    var setSelected = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        tableView.addGestureRecognizer(longPress)
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
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if taskSegmentControl.selectedSegmentIndex == 1 {
                    setSelected = true
                    let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
                    if setSelected {
                        taskIdArray.append(cell.taskId ?? 0)
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blue
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "delete"), style: .plain, target: self, action: #selector(AddTaskClicked(_:)))
                    }
                    
                }
                
                // your code here, get the row for the indexPath or do whatever you want
                print("Long press Pressed:)")
            }
        }
    }
    func changeBarButtonItemImage(_ item: UIBarButtonItem, image: UIImage, navItem: UINavigationItem) -> UIBarButtonItem? {
        
        let buttonItem = UIBarButtonItem(image: image, style: item.style, target: item.target, action: item.action)
        buttonItem.isEnabled = item.isEnabled
        
        if let leftIndex = navItem.leftBarButtonItems?.index(of: item) {
            var items: [UIBarButtonItem] = navItem.leftBarButtonItems!
            items[leftIndex] = buttonItem
            navItem.leftBarButtonItems = items
            return buttonItem
        }
        
        if let rightIndex = navItem.rightBarButtonItems?.index(of: item) {
            var items: [UIBarButtonItem] = navItem.rightBarButtonItems!
            items[rightIndex] = buttonItem
            navItem.rightBarButtonItems = items
            return buttonItem
        }
        
        return nil
    }
    @IBAction func AddTaskClicked(_ sender: UIBarButtonItem) {
        if setSelected {
            CoreDataManager.shared.deleteTasks(taskIdArray: taskIdArray)
            viewModel?.reloadTasks(completionHandler: { (result) in
                DispatchQueue.main.async {
                    self.setSelected = false
                    if result {
                        
                        //  self.loader.hideOverlayView()
                        self.tableView.reloadData()
                    }
                }
            })
        } else {
            createNewTask()
        }
        
    }
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blue
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: .add, style: .plain, target: self, action: #selector(AddTaskClicked(_:)))
        default:
            self.navigationItem.rightBarButtonItem = nil
            //self.navigationItem.rightBarButtonItem?.isEnabled = false
            //self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            
            
        }
        setSelected = false
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
        cell.accessoryType = UITableViewCell.AccessoryType.none

        cell.textLabel!.text = viewModel?.getTaskName(for: indexPath, status: taskSegmentControl.selectedSegmentIndex)
        cell.taskId = viewModel?.getTaskId(for: indexPath, status: taskSegmentControl.selectedSegmentIndex)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
        if setSelected {
            taskIdArray.append(cell.taskId ?? 0)
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
    }
    
}
