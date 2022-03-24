//
//  AllListsTableViewController.swift
//  Checklists0210
//
//  Created by 황신택 on 2022/02/13.
//

import UIKit

class AllListsTableViewController: UITableViewController {
    let cellIdentifier = "ChecklistCell"
    var dataModel: DataModel!
    
    // MARK: - Navigation
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! CheckListTableViewController
            controller.checklist = sender as? Checklist
        } else if segue.identifier == "AddChecklist" {
            let controller = segue.destination as! ListDetailTableViewController
            controller.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        for list in dataModel.lists {
            let item = ChecklistItem(text: "Item for \(list.name)", checked: false)
            list.items.append(item)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist
        if index >= 0 && index < dataModel.lists.count {
            // 유저가 add, edit화면으로 이동하게되면 인덱스 -1이 아님.
            // 유저가 뒤로가기 하는순간 무조건 -1이 저장되게 해놨음 즉 앱을 실행했을시 메인뷰를 보여줄건지 아니면 서브뷰를 보여줄건지 정하는 로직.
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        let checklist = dataModel.lists[indexPath.row]
        if let tmp = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = tmp
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel?.text = checklist.name
        cell.imageView?.image = UIImage(named: checklist.iconName)
        
        if checklist.checkAllDone() {
            cell.detailTextLabel?.text = "AllDone"
        } else if checklist.items.count == 0 {
            cell.detailTextLabel?.text = "No Items"
        } else {
            cell.detailTextLabel?.text = "\(checklist.countUncheckedItems()) Remaining"
        }
        
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let checklist = dataModel.lists[indexPath.row]
        
        // 만약 유저가
        dataModel.indexOfSelectedChecklist = indexPath.row
        
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataModel.lists.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ListDetailVC") as! ListDetailTableViewController
        controller.delegate = self
        
        let checklist = dataModel.lists[indexPath.row]
        controller.checkListToEdit = checklist
        
        navigationController?.pushViewController(controller, animated: true)
    }
}


extension AllListsTableViewController: ListDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ListDetailTableViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailTableViewController, didFinishAdding checklist: Checklist) {
        dataModel.lists.append(checklist)
        dataModel.sortChecklist()
        let indexPath = IndexPath(row: dataModel.lists.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailTableViewController, didFinishEditing checklist: Checklist) {
        if let index = dataModel.lists.firstIndex(of: checklist) {
            dataModel.lists[index] = checklist
            dataModel.sortChecklist()
            let indexpath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexpath], with: .automatic)
        }
        
        navigationController?.popViewController(animated: true)
    }
}


extension AllListsTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController === self {
            dataModel.indexOfSelectedChecklist = -1
        }
    }
}
