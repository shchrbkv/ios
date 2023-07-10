//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Alex Scherbakov on 7/30/22.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate{
    
    var dataModel: DataModel!
    
    let cellIdentifier = "ChecklistCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
    
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist
        
        if index >= 0 && index < dataModel.lists.count {
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - TableView Delegate

    // Used to precalculate how many rows there will be
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.lists.count
    }

    // Used for recycling cells in table view by requesting cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell!
        
        if let temp = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = temp
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let checklist = dataModel.lists[indexPath.row]
        let unchecked = checklist.uncheckedItemsCount
        
        cell.textLabel!.text = checklist.name
        
        if checklist.items.count == 0 {
            cell.detailTextLabel!.text = "No Items"
        }
        else {
            cell.detailTextLabel!.text = unchecked == 0 ? "Completed" : "\(unchecked) remaining"
        }
        
        cell.accessoryType = .detailDisclosureButton
        cell.imageView!.image = UIImage(named: checklist.iconName)
        
        return cell
    }
    
    // The tap itself, also known as selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dataModel.indexOfSelectedChecklist = indexPath.row
        
        let checklist = dataModel.lists[indexPath.row]
        
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    // Tapping on (i) button
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let checklist = dataModel.lists[indexPath.row]
        
//        performSegue(withIdentifier: "EditChecklist", sender: checklist)
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "ListDetailViewController") as! ListDetailViewController
        
        controller.delegate = self
        controller.checklistToEdit = checklist
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    // Editing of the table, here used to delete rows/cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        dataModel.lists.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        
        // Remove cells from view
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // MARK: - Checklist Details Delegate

    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        
//        let newRowIndex = dataModel.lists.count
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
//
//        let indexPath = IndexPath(row: newRowIndex, section: 0)
//        let indexPaths = [indexPath]
//        tableView.insertRows(at: indexPaths, with: .automatic)

        navigationController?.popViewController(animated: false)
        
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        
        dataModel.sortChecklists()
        if let index = dataModel.lists.firstIndex(of: checklist) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel!.text = checklist.name
            }
        }
        
        navigationController?.popViewController(animated: true)
    }


    // MARK: - Navigation
    
    // Delegate for navigation controller that is called before segue to viewController
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if viewController === self {
            dataModel.indexOfSelectedChecklist = -1
        }
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "ShowChecklist":
            // Get the new view controller using segue.destination.
            let controller = segue.destination as! ChecklistViewController
            
            // Pass the selected object to the new view controller.
            controller.checklist = sender as? Checklist
            
        case "AddChecklist":
            // Get the new view controller using segue.destination.
            let controller = segue.destination as! ListDetailViewController
            
            // Pass the selected object to the new view controller.
            controller.delegate = self
        
        case "EditChecklist":
            // Get the new view controller using segue.destination.
            let controller = segue.destination as! ListDetailViewController
            
            // Pass the selected object to the new view controller.
            controller.delegate = self
            controller.checklistToEdit = sender as? Checklist
            
        default:
            return
        }
        
    }
}
