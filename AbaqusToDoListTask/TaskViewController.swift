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
    override func viewDidLoad() {
        super.viewDidLoad()
         
        initViewModel()
         
    }
    func initViewModel(){
       viewModel?.getUsers(completionHandler: { (result) in
                   DispatchQueue.main.async {
                       if result {
                         //  self.loader.hideOverlayView()
                           self.tableView.reloadData()
                       }
                   }
               })
    }
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        tableView.reloadData()
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
