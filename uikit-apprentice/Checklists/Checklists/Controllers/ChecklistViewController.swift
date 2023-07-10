//
//  ViewController.swift
//  Checklists
//
//  Created by Alex Scherbakov on 7/29/22.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {

    var items: [ChecklistItem] = []
    
    var checklist: Checklist!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.largeTitleDisplayMode = .never
        
        title = checklist.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    func configureCheckmark(
        for cell: UITableViewCell,
        with item: ChecklistItem
    ) {
        let label = cell.viewWithTag(70) as! UILabel
        
        if item.checked {
            label.text = "✔️"
        } else {
            label.text = ""
        }
    }
    
    func configureText(
        for cell: UITableViewCell,
        with item: ChecklistItem
    ) {
        let label = cell.viewWithTag(69) as! UILabel
        label.text = item.text
    }
    
    // MARK: - TableView Delegate
    
    // Used to precalculate how many rows there will be
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    // Used for recycling cells in table view by requesting cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        let item = checklist.items[indexPath.row]
        
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        
        return cell
    }
    
    // The tap itself, also known as selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = checklist.items[indexPath.row]
            
            item.checked.toggle()
            
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Editing of the table, here used to delete rows/cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        checklist.items.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        
        // Remove cells from view
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    
    // MARK: - Item Details Delegate
    
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
        
        checklist.items.append(item)
        checklist.sortItems()
        
        navigationController?.popViewController(animated: true)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
        
//        if let index = checklist.items.firstIndex(of: item) {
//            let indexPath = IndexPath(row: index, section: 0)
//            if let cell = tableView.cellForRow(at: indexPath) {
//                configureText(for: cell, with: item)
//            }
//        }
        
        checklist.sortItems()
        
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AddItem":
            let controller = segue.destination as! ItemDetailViewController
            
            controller.delegate = self
            
        case "EditItem":
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        default:
            return
        }
    }

}

