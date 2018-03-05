//
//  ModelListOptionsTableViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 10/02/2018.
//

import UIKit
import CoreData

public protocol ModelListOptionsDelegate {
    func onNewListAvailable(newList:ModelList, selectedSearchableAttributes:[String:NSAttributeDescription])
}

class ModelListOptionsTableViewController: UITableViewController   {
    
    public var listDelegate:ModelListOptionsDelegate?
    public var initialList: ModelList!
    public var newList:ModelList?
    
    private var sort:Sort?
    
    public var searchableAttributes:[String:NSAttributeDescription]!
    public var selectedSearchableAttributes:[String:NSAttributeDescription]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancel(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
        }
        
        if let l = newList, listDelegate != nil {
            self.listDelegate?.onNewListAvailable(newList: l, selectedSearchableAttributes: self.selectedSearchableAttributes)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0){
            return 1
        }
       
        return self.searchableAttributes.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Sorting Preferences:"
        }
        return "Select Searchable Fields:"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell!
        
        
        if(indexPath.section == 0){
        
            cell = tableView.dequeueReusableCell(withIdentifier: "MoldelListSelectSortTableCell", for: indexPath)
        
            if let sortCell:MoldelListSelectSortTableCell = cell as? MoldelListSelectSortTableCell {
                setupSortOptionCell(cell:sortCell)
            }
        }
        
        if(indexPath.section == 1){
            
            cell = tableView.dequeueReusableCell(withIdentifier: "SelectSearchAttributeTableViewCell", for: indexPath)
            
            if let searchCell:SelectSearchAttributeTableViewCell = cell as? SelectSearchAttributeTableViewCell {
                setupSelectSearchAttributeTableViewCell(cell:searchCell, forIndex: indexPath.row)
            }
        }
        
        // Configure the cell...

        return cell
    }
 
    private func setupSortOptionCell(cell:MoldelListSelectSortTableCell) {
        cell.initialSetup(tableController: self)
    }
    
    private func setupSelectSearchAttributeTableViewCell(cell:SelectSearchAttributeTableViewCell, forIndex:Int){
        let names = Array(self.searchableAttributes.keys)
        cell.labelName.text = names[forIndex]
        cell.controller = self
        cell.switchSelected.setOn(self.selectedSearchableAttributes[names[forIndex]] != nil, animated: false)
        
    }
    
    public func onSearchFieldSwitchSelected(sender:UISwitch, name:String){
        
        if(sender.isOn){
            
            if(self.newList == nil){
                self.newList = self.initialList
            }
            
            self.selectedSearchableAttributes[name] = self.searchableAttributes[name]
        }else {
            if(self.selectedSearchableAttributes[name] != nil &&
                self.selectedSearchableAttributes.count > 1 ) {
                self.selectedSearchableAttributes.removeValue(forKey: name)
                if(self.newList == nil){
                    self.newList = self.initialList
                }
            }else {
                sender.setOn(true, animated: false)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func getNewList() -> ModelList{
        
        if let l = self.newList  {
            return l
        }
        
        
        return self.initialList
    }
    
    // MARK: - Sort Options
    
    func sortOrderChanged(field:String, order:SortOption.Order) {
        
        let list = getNewList()
        let sort:Sort = Sort()
        sort.add(field: field, order: order)
        self.newList = list.clone(newFilter: nil, newSort: sort)
    }
    
    func sortingOptions() -> [String:NSAttributeDescription] {
    
        if let list = self.initialList{
            return  list.entity.attributesByName
        }
        return [:]
    }
    
}
