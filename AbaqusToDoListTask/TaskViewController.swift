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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelView: UIView!
    
    @IBOutlet weak var changeStateLabel: UILabel!
    
    
    var taskIdArray : [Int] = []
    var isCellSelected = false
    var changeState = true
    var refreshControl = UIRefreshControl()
    weak var actionToEnable : UIAlertAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        initViewModel()
        
    }
    
    func configureUI() {
        // navigation bar button item
        
        addNavigationItem(imageName: "add_circleblack")
        
        // table view
        tableView.tableFooterView = UIView()
        tableView.layer.borderWidth = 2
        tableView.layer.borderColor = UIColor.white.cgColor
        
        // long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        
        // pull to refresh
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        
    }
    
    func initViewModel(){
        if !UserDefaults.standard.bool(forKey: "isAppFirstTimeLaunched") {
            showHUD(message: "")
            DispatchQueue.global(qos: .background).async {
                self.viewModel?.getTasks(completionHandler: { (result) in
                    if result {
                        self.reloadTaskList(showLoader: true)
                    }
                    
                })
            }
        } else {
            self.reloadTaskList(showLoader: true)
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        reloadTaskList(showLoader: false)
    }
    
    
    func reloadTaskList(showLoader: Bool) {
        if showLoader {
            self.showHUD(message: "")
        }
        viewModel?.reloadTasks(completionHandler: { (result) in
            DispatchQueue.main.async {
                self.isCellSelected = false
                if result {
                    self.hideHUD()
                    if !showLoader {
                        self.refreshControl.endRefreshing()
                        if self.taskSegmentControl.selectedSegmentIndex == 1 {
                            self.navigationItem.rightBarButtonItem = nil
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    // MARK: - segment controller action
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            taskIdArray = []
            addNavigationItem(imageName: "add_circleblack")
        default:
            self.navigationItem.rightBarButtonItem = nil
            
        }
        isCellSelected = false
        tableView.reloadData()
    }
    
    // MARK: - Add navigation bar button item
    
    func addNavigationItem(imageName : String) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: self, action: #selector(AddDeleteTaskClicked(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = .systemTeal
    }
    
    // MARK: - Add/delete task
    
    @objc func textChanged(_ sender:UITextField) {
        self.actionToEnable?.isEnabled  = (sender.text!.count > 0)
    }
    func createNewTask() {
        let alertController = UIAlertController(title: "Add New Task", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField(configurationHandler: {(textField: UITextField) in
                   textField.placeholder = "Enter TaskName"
                   textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
               })
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.insertTaskinDB(taskName: firstTextField.text ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.actionToEnable = saveAction
        saveAction.isEnabled = false
        
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    func insertTaskinDB(taskName: String) {
        showHUD(message: "Please wait")
        let lastId = CoreDataManager.shared.fetchLastId()
        print(lastId)
        let taskModel = TasksModel(id: lastId, task: taskName, state: 0)
        CoreDataManager.shared.saveTaskData(taskModel: taskModel)
        reloadTaskList(showLoader: true)
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
        // get the row for the indexPath
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                if taskSegmentControl.selectedSegmentIndex == 1 {
                    isCellSelected = true
                    let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
                    
                    if isCellSelected {
                        taskIdArray.append(cell.taskId ?? 0)
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        
                        addNavigationItem(imageName: "delete")
                    }
                    
                }
                
            }
        }
    }
    
    @objc func AddDeleteTaskClicked(_ sender: UIBarButtonItem) {
        
        if isCellSelected {
            showHUD(message: "")
            CoreDataManager.shared.deleteTasks(taskIdArray: taskIdArray)
            viewModel?.reloadTasks(completionHandler: { (result) in
                DispatchQueue.main.async {
                    self.isCellSelected = false
                    
                    if result {
                        self.hideHUD()
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        self.navigationItem.rightBarButtonItem?.tintColor = .clear
                        self.tableView.reloadData()
                    }
                    
                }
            })
        } else {
            createNewTask()
        }
        
    }
    
     // MARK: - change state
    
    func changeSate(id: Int, name : String) {
        if changeState {
            showHUD(message: "Please wait")
            let taskModel : TasksModel = TasksModel(id: id, task: name, state: taskSegmentControl.selectedSegmentIndex == 0 ? 1 : 0)
            CoreDataManager.shared.saveTaskData(taskModel: taskModel)
            reloadTaskList(showLoader: true)
            
        }
    }
    
    @objc func cancelChangingState() {
        changeState = false
        tableView.reloadData()
    }
    
    @IBAction func cancelStateAction(_ sender: UIButton) {
        changeState = false
        setView(view: cancelView, hidden: true)
        reloadTaskList(showLoader: true)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.7, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }

}

    // MARK: - Table view data source, datasource
extension TaskViewController : UITableViewDelegate, UITableViewDataSource {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return viewModel.numberOfTaskToDisplay(in: taskSegmentControl.selectedSegmentIndex, row: 0)
        return viewModel.taskResults?.filter { $0.state == taskSegmentControl.selectedSegmentIndex }.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        
        let task = viewModel.taskResults?.filter { $0.state == taskSegmentControl.selectedSegmentIndex }[indexPath.row]
        cell.accessoryView = nil
        cell.accessoryType = UITableViewCell.AccessoryType.none
        cell.textLabel!.textColor = .white
        cell.textLabel!.numberOfLines = 0
 
        cell.textLabel!.text = task?.task
        
        cell.taskId = task?.id
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
        if isCellSelected {
            if taskIdArray.contains(cell.taskId ?? 0) {
                if let index = taskIdArray.firstIndex(of: cell.taskId ?? 0) {
                    taskIdArray.remove(at: index)
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
            } else {
                taskIdArray.append(cell.taskId ?? 0)
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            
        } else {
            changeState = true
            let taskIndex = viewModel.taskResults?.firstIndex(where: { ( $0.id == cell.taskId ) } ) ?? 0
            viewModel.taskResults?.remove(at: taskIndex)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            
            setView(view: cancelView, hidden: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.setView(view: self.cancelView, hidden: true)
                self.changeSate(id: cell.taskId ?? 0, name: cell.textLabel?.text ?? "")
            }
        }
    }
    
    
}
