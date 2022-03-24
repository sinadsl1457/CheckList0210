//
//  AddItemTableViewController.swift
//  Checklists0210
//
//  Created by 황신택 on 2022/02/11.
//

import UIKit
import UserNotifications

protocol ItemDetailViewControllerDelegate: AnyObject {
    func addItemViewControllerDidCancel(_ controller: ItemDetailTableViewController)
    func addItemViewController(_ controller: ItemDetailTableViewController,
                               didFinishAdding item: ChecklistItem)
    func editItemViewController(_ controller: ItemDetailTableViewController,
                                didFinishingEditing item: ChecklistItem)
}

extension Notification.Name {
    static let addItem = Notification.Name("addItem")
}

class ItemDetailTableViewController: UITableViewController {
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: ItemDetailViewControllerDelegate?
    var item: ChecklistItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = item {
            title = "Edit item"
            itemTextField.text = item.text
            shouldRemindSwitch.isOn = item.shouldRemind
            datePicker.date = item.dueDate
        }
        doneBarButton.isEnabled = itemTextField.text!.count > 0
        itemTextField.becomeFirstResponder()
        itemTextField.font = UIFont.systemFont(ofSize: 17)
        itemTextField.placeholder = "Name of the Item"
        itemTextField.autocapitalizationType = .sentences
        itemTextField.returnKeyType = .done
        itemTextField.enablesReturnKeyAutomatically = true
        itemTextField.delegate = self
        itemTextField.clearButtonMode = .always
        
    }
    
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        itemTextField.resignFirstResponder()
        
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {_, _ in
                // do nothing
            }
        }
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.addItemViewControllerDidCancel(self)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let text = itemTextField.text else { return }
        
        if let item = item {
            item.text = text
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate?.editItemViewController(self, didFinishingEditing: item)
        } else {
            let item = ChecklistItem(text: text, checked: false)
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate?.addItemViewController(self, didFinishAdding: item)
        }
    }
    
}


extension ItemDetailTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
              let range = Range(range, in: oldText)
        else { return false }
        
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
}
