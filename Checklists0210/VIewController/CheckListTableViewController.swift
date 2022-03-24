//
//  CheckListTableViewController.swift
//  Checklists0210
//
//  Created by 황신택 on 2022/02/10.
//

import UIKit

class CheckListTableViewController: UITableViewController {
     var checklist: Checklist!
    
    let dateFormatter: DateFormatter = {
       let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .short
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = checklist.name
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            if let controller = segue.destination as? ItemDetailTableViewController {
                controller.delegate = self
            }
        }
        
        if segue.identifier == "EditItem" {
            if let controller = segue.destination as? ItemDetailTableViewController,
               let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                controller.delegate = self
                controller.item = checklist.items[indexPath.row]
            }
        }
    }
    
   
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return checklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        let target = checklist.items[indexPath.row]
        
        configureText(for: cell, with: target)
        configureCheckmark(for: cell, with: target)
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let target = checklist.items[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            target.checked.toggle()
            
            configureCheckmark(for: cell, with: target)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            checklist.items.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
}


extension CheckListTableViewController {
    func configureText(
        for cell: UITableViewCell,
        with item: ChecklistItem
    ) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = "\(item.itemID): \(item.text)"
        let detailLabel = cell.viewWithTag(1002) as! UILabel
        detailLabel.text = dateFormatter.string(from: item.dueDate)
    }
    
    func configureCheckmark(
        for cell: UITableViewCell,
        with item: ChecklistItem
    ) {
        
        let checkmarkLabel = cell.viewWithTag(1001) as! UILabel
        
        if item.checked {
            checkmarkLabel.text = "✓"
        } else {
            checkmarkLabel.text = ""
        }
    }
    
}


extension CheckListTableViewController: ItemDetailViewControllerDelegate {
    func addItemViewControllerDidCancel(_ controller: ItemDetailTableViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addItemViewController(_ controller: ItemDetailTableViewController, didFinishAdding item: ChecklistItem) {
        checklist.items.append(item)
        checklist.items.sort {
            $0.dueDate < $1.dueDate
        }
        let indexPath = IndexPath(row: checklist.items.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        navigationController?.popViewController(animated: true)
    }
    
    
    func editItemViewController(_ controller: ItemDetailTableViewController, didFinishingEditing item: ChecklistItem) {
        if let index = checklist.items.firstIndex(where: { $0.id == item.id }) {
            checklist.items[index] = item
            checklist.items.sort {
                $0.dueDate < $1.dueDate
            }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            navigationController?.popViewController(animated: true)
        }
    }
}

