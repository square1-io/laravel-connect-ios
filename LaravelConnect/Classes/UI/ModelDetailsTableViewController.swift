//
//  ModelDetailsTableViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 05/02/2018.
//

import UIKit

private let ATTRIBUTES_LABEL = "Attributes"
private let ONE_LABEL = "One Relations"
private let MANY_LABEL = "Many Relations"

class ModelDetailsTableViewController: UITableViewController {
    
    public var model:ConnectModel?
    public var modelId:Any?
    public var modelType:ConnectModel.Type?
    
    
    public var sections:Array<[String]>?
    public var sectionsNames:Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var sec = Array<[String]>()
        var secNames = Array<String>()
        
        if let keys = self.model?.attributes.keys {
             var attr = Array(keys)
             attr.sort()
             sec.append(attr)
             secNames.append(ATTRIBUTES_LABEL)
        }
        
        if let keys = self.model?.oneRelations.keys {
            var ones = Array(keys)
            ones.sort()
            sec.append(ones)
            secNames.append(ONE_LABEL)
        }
        
        if let keys = self.model?.manyRelations.keys {
            var manys = Array(keys)
            manys.sort()
            sec.append(manys)
            secNames.append(MANY_LABEL)
        }
        
        self.sections = sec
        self.sectionsNames = secNames
        
        if let id:Any = self.model?.primaryKey,
            let path:String = self.model!.modelPath{
            self.title =  "\(path)\\\(id)"
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        guard let s = sections else { return 0}
        return s.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        if let s:[String] = self.sections?[section] {
            return s.count
        }
        
        return 0

    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return self.sectionsNames?[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = self.sectionsNames![indexPath.section]
        
        var cell:UITableViewCell
        
        if(ATTRIBUTES_LABEL.elementsEqual(currentSection)){
            cell = tableView.dequeueReusableCell(withIdentifier: "ModelAttributeCell", for: indexPath)
            self.setAttributeCell(cell: cell as! ModelAttributeCell, indexPath: indexPath)
        }
        else if(ONE_LABEL.elementsEqual(currentSection)){
            cell = tableView.dequeueReusableCell(withIdentifier: "OneRelationCell", for: indexPath)
            self.setOneRelationCell(cell: cell as! OneRelationCell, indexPath: indexPath)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "ManyRelationCell", for: indexPath)
            self.setManyRelationCell(cell: cell as! ManyRelationCell, indexPath: indexPath)
        }
        
        return cell
    }
    
    private func setAttributeCell(cell:ModelAttributeCell, indexPath:IndexPath){

        if let sec = self.sections,
            let secIndex:Int = indexPath.section,
            let attributes:[String] = sec[secIndex],
            let name:String = attributes[indexPath.row],
            let attribute = self.model?.attributes[name],
            let value = self.model?.value(forKey: name){
            
            cell.labelName.text = name.capitalized
            cell.labelType.text = attribute.attributeValueClassName?.lowercased()
            cell.labelValue.text = String( describing: value )
            
        }
    }
    
    private func oneRelationForIndexPath(indexPath:IndexPath?) -> ConnectOneRelationProtocol?{
        
        if let sec = self.sections,
            let secIndex:Int = indexPath?.section,
            let attributes:[String] = sec[secIndex],
            let secRow:Int = indexPath?.row,
            let name:String = attributes[secRow],
            let r = self.model?.connectRelations![name],
            let relation:ConnectOneRelationProtocol = r as? ConnectOneRelationProtocol {
                return relation
            }
        
        return nil
    }
    
    private func setOneRelationCell(cell:OneRelationCell, indexPath:IndexPath){
        
        if let relation:ConnectOneRelationProtocol = self.oneRelationForIndexPath(indexPath: indexPath),
            let value = relation.relatedId {
            cell.labelName.text = relation.name.capitalized
            cell.labelType.text = String(describing: relation.relatedModel)
            cell.labelValue.text = String( describing: value )

        }
    }
    
    private func setManyRelationCell(cell:ManyRelationCell, indexPath:IndexPath){
        
//        if let sec = self.sections,
//            let secIndex:Int = indexPath.section,
//            let attributes:[String] = sec[secIndex],
//            let name:String = attributes[indexPath.row],
//            let attribute = self.model?.attributes[name],
//            let value = self.model?.value(forKey: name){
//
//            cell.labelName.text = name.capitalized
//            cell.labelType.text = attribute.attributeValueClassName?.lowercased()
//            cell.labelValue.text = String( describing: value )
//
//        }
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

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let indexPath = self.tableView.indexPathForSelectedRow
        let segueIdentifier:String = segue.identifier != nil ? segue.identifier! : ""
        
        if ("OneRelationSegue".elementsEqual(segueIdentifier)) {
            
            if let controller:ModelDetailsTableViewController? = segue.destination as? ModelDetailsTableViewController,
                let model = self.oneRelationForIndexPath(indexPath: indexPath) {
                controller?.model = model.object()
            }
        }
      
    }
    

}
