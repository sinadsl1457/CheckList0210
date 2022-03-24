//
//  Checklist.swift
//  Checklists0210
//
//  Created by 황신택 on 2022/02/13.
//

import Foundation

class Checklist: NSObject, Codable {
    var name: String
    var items = [ChecklistItem]()
    var iconName: String
    
    
    init(name: String, iconName: String = "No Icon") {
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    func countUncheckedItems() -> Int {
        items.reduce(0) { cnt, item in
            cnt + (item.checked ? 0 : 1)
        }
    }
    
    func checkAllDone() -> Bool {
        var checked = false
        for item in items {
            checked = item.checked
        }
        
        if checked {
            return true
        } else {
            return false
        }
    }
}
