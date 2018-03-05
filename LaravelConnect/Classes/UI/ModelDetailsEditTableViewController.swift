//
//  ModelListOptionsTableViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 10/02/2018.
//

import UIKit
import CoreData


struct EditHelper {
    
    let name:String
    let cellReusableId:String
    let initialValue:Any?
    var newValue:Any?
    
    func updated() -> Bool {
        
        if  initialValue != nil, newValue != nil {
            
            let v1:String = String(describing: initialValue)
            let v2:String = String(describing: newValue)
            
            return v1 != v2
        }
        
        return false
    }
    
    func value() -> Any {
        if let v = newValue {
            return v
        }
        return ""
    }
 
}

class BaseEditTableViewCell: UITableViewCell {
    
    weak var controller:ModelDetailsEditTableViewController?
    var field:EditHelper!
    
    public func setEditableField(editable:EditHelper){
        self.field = editable
    }
    
    public func notifyUpdate(){
        if let c = controller {
            c.onFieldChanged(field: self.field)
        }
    }
}



public class ModelDetailsEditNavigationController: UINavigationController {
 
    public var model:ConnectModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if let controller:ModelDetailsEditTableViewController = self.childViewControllers.first as? ModelDetailsEditTableViewController {
           controller.model = self.model
        }
    }
}

class ModelDetailsEditTableViewController : UITableViewController   {
    
    public var model:ConnectModel!
    
    private var editableFields:[String:EditHelper]!
    private var editableFieldsName:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.editableFields = Dictionary()
        self.editableFieldsName = Array()
        
        for(name,attribute) in self.model.editableAttributes {
            self.editableFieldsName.append(name)
            let type = attribute.attributeType
            var field:EditHelper
            print("atttibute \(attribute.name) = \(attribute.attributeValueClassName) \(attribute.attributeType.rawValue) "    )
            switch(type){
            case .doubleAttributeType,
             .integer16AttributeType,
             .integer32AttributeType,
             .integer64AttributeType,
             .decimalAttributeType,
             .floatAttributeType,
             .booleanAttributeType:
                let value = self.model.numberAttribute(name: name)
                field = EditHelper(name: name, cellReusableId:"EditNumberAttributeTableViewCell", initialValue: value, newValue: value)
                
            default:
                let value = self.model.stringAttribute(name: name)
                field = EditHelper(name: name, cellReusableId:"EditStringAttributeTableViewCell", initialValue: value, newValue: value)
            }
            self.editableFields[name] = field
        }

        self.editableFieldsName.sort()
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
        
        var updated = false
        
        for (_,field) in self.editableFields {
            
            if(field.updated() == true ) {
                updated = true
                print( "updated \(field.name) to \(field.value())")
                self.model.setValue(field.value(), forKey: field.name)
            }
            
        }
        
        if(updated == true) {
            
            self.model.save(done: { (objId, error) in
                
                guard  error == nil else {
                    self.showErrorDialog(error: error!)
                    return;
                }
                self.showResultDialog()
            })
        }
        
    }
    
    private func showResultDialog (){

        let alert = UIAlertController(title: "Saved", message: "Changed Saved", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler:{(action) in
            if((self.presentingViewController) != nil){
                self.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func showErrorDialog (error:Error){
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    public func onFieldChanged(field:EditHelper) {
        self.editableFields[field.name] = field
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.editableFieldsName.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = editableFieldsName[indexPath.row]
        let field = self.editableFields[name]!
        
        let cell:BaseEditTableViewCell = tableView.dequeueReusableCell(withIdentifier: field.cellReusableId, for: indexPath) as! BaseEditTableViewCell
        cell.controller = self
        cell.setEditableField(editable: field )

        return cell
    }


    
}
