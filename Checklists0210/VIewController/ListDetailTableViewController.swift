//
//  ListDetailTableViewController.swift
//  Checklists0210
//
//  Created by 황신택 on 2022/02/13.
//

import UIKit

protocol ListDetailViewControllerDelegate: AnyObject {
    func listDetailViewControllerDidCancel(
        _ controller: ListDetailTableViewController)
    
    func listDetailViewController(
        _ controller: ListDetailTableViewController,
        didFinishAdding checklist: Checklist
    )
    
    func listDetailViewController(
        _ controller: ListDetailTableViewController,
        didFinishEditing checklist: Checklist
    )
}


class ListDetailTableViewController: UITableViewController {
    var delegate: ListDetailViewControllerDelegate?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    var checkListToEdit: Checklist?
    var iconName = "Folder"
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let text = textField.text else { return }
        
        if let checkListToEdit = checkListToEdit {
            checkListToEdit.name = text
            checkListToEdit.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditing: checkListToEdit)
        } else {
            let checklist = Checklist(name: text, iconName: iconName)
            delegate?.listDetailViewController(self, didFinishAdding: checklist)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? IconPickerTableViewController {
            controller.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let checkListToEdit = checkListToEdit {
            title = "Edit Checklist"
            doneBarButton.isEnabled = true
            textField.text = checkListToEdit.name
        }
        
        if let checkListToEdit = checkListToEdit {
            iconName = checkListToEdit.iconName
        }
        
        iconImage.image = UIImage(named: iconName)
        setUpTextField()
    }
    
    private func setUpTextField() {
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "Name of the List"
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
    }

    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 1 ? indexPath : nil
    }
}


extension ListDetailTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
              let stringRange = Range(range, in: oldText) else { return false }
        
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
}


extension ListDetailTableViewController: IconPickerViewControllerDelegate {
    func iconPicker(_ picker: IconPickerTableViewController, didPick IconName: String) {
        iconName = IconName
        
        navigationController?.popViewController(animated: true)
    }
    
    
}
