//
//  ModelListOptionsTableViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 10/02/2018.
//

import UIKit
import CoreData

protocol EditHelperProtocol {
    
    var name:String {get }
    var cellReusableId:String {get }
    var initialValue:Any? {get }
    var newValue:Any? {get set}
    
    func updated() -> Bool
    func value() -> Any
    
}
struct EditHelper: EditHelperProtocol {
    
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
        
        return true
    }
    
    func value() -> Any {
        if let v = newValue {
            return v
        }
        return ""
    }
}

struct UploadedFileHelper: EditHelperProtocol {
    
    let name:String
    let cellReusableId:String
    let initialValue:Any?
    var newValue:Any?
    
    func updated() -> Bool {
        
        if let initialV:UploadedImage = initialValue as? UploadedImage ,
            let newV:UploadedImage = newValue as? UploadedImage {
            return initialV != newV
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

struct ManyEditHelper : EditHelperProtocol {
   
    func value() -> Any {
        var val = Dictionary<String,Array<ConnectModel>>()
        if let add:Array = self.add, add.count > 0 {
            val["add"] = add
        }
        if let remove:Array = self.remove, remove.count > 0 {
            val["remove"] = remove
        }
        return val
    }
    
    
    
    let name:String
    let cellReusableId:String
    let initialValue:Any?
    var newValue:Any?
    
    var add:Array<ConnectModel>?
    var remove:Array<ConnectModel>?

    func updated() -> Bool {
        
        if let a = self.add, a.count > 0 {
            return true
        }
        
        if let r = self.remove, r.count > 0 {
            return true
        }
 
        return false
    }
}

class BaseEditTableViewCell: UITableViewCell {
    
    weak var controller:ModelDetailsEditTableViewController?
    var field:EditHelperProtocol!
    
    public func setEditableField(editable:EditHelperProtocol){
        self.field = editable
    }
    
    public func notifyUpdate(){
        if let c = controller {
            c.onFieldChanged(field: self.field)
        }
    }
}



public class ModelDetailsEditNavigationController: UINavigationController  {
    
 
    public var model:ConnectModel!
  
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if let controller:ModelDetailsEditTableViewController = self.childViewControllers.first as? ModelDetailsEditTableViewController {
           controller.model = self.model
        }
    }
}

class ModelDetailsEditTableViewController : UITableViewController, ModelListTableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    public var model:ConnectModel!
    private var presenter:ModelPresenter!
    
    private var selectedImageEditHelper:EditHelperProtocol?
    
    private var editableFields:[String:EditHelperProtocol]!
    private var editableFieldsName:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         imagePicker.delegate = self
    
        self.presenter = LaravelConnect.shared().presenterForClass(className: self.model.className)
        
        self.setTitle()
        
        self.editableFields = Dictionary()
        self.editableFieldsName = Array()
        
        for(name,attribute) in self.model.editableAttributes {
            self.editableFieldsName.append(name)
            let type = attribute.attributeType
            var field:EditHelperProtocol
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
                break
            case .transformableAttributeType:
                field = self.fieldForTrasformable(name: name, attribute: attribute)
                break
            case .dateAttributeType:
                field = self.fieldForDate(name: name, attribute: attribute)
                break
            default:
                let value = self.model.stringAttribute(name: name)
                field = EditHelper(name: name, cellReusableId:"EditStringAttributeTableViewCell", initialValue: value, newValue: value)
            }
            self.editableFields[name] = field
        }
        
        //add one relation
        for(name,relation) in self.model.connectRelations {
            
            if let re:ConnectOneRelationProtocol = relation as? ConnectOneRelationProtocol {
                self.editableFieldsName.append(name)
                let field = EditHelper(name: name, cellReusableId:"EditOneRelationTableViewCell", initialValue: re.object(), newValue: re.object())
                self.editableFields[name] = field
            }
            
            if let re:ConnectManyRelationProtocol = relation as? ConnectManyRelationProtocol {
                self.editableFieldsName.append(name)
                
                let field = ManyEditHelper(name: name, cellReusableId:"EditManyRelationTableViewCell", initialValue:"", newValue:"Edit Relation", add: nil, remove: nil)
                self.editableFields[name] = field
            }

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
    
    private func fieldForTrasformable(name:String, attribute:NSAttributeDescription) -> EditHelperProtocol{
    
        if let transformable = attribute.valueTransformerName {
            
            if(transformable.elementsEqual(NSValueTransformerName.UploadedImageCoreDataTransformerName.rawValue)){
            let value = self.model.uploadedImageAttribute(name: name)
             return UploadedFileHelper(name: name, cellReusableId:"EditUploadedImageTableViewCell", initialValue: value, newValue: value)
            }
            
        }
        
        let value = self.model.stringAttribute(name: name)
        return  EditHelper(name: name, cellReusableId:"EditStringAttributeTableViewCell", initialValue: value, newValue: value)
    
    }
    
    private func fieldForDate(name:String, attribute:NSAttributeDescription) -> EditHelperProtocol{
        
        let value = self.model.dateAttribute(name: name)
        return  EditHelper(name: name, cellReusableId:"EditDateTimeTableViewCell", initialValue: value, newValue: value)
        
    }
    
    @IBAction func save(sender: AnyObject) {
        
        var updated = false
        
        for (_,field) in self.editableFields {
            
            if(field.updated() == true ) {
                updated = true
                
                 if let paramHelper:ManyEditHelper = field as? ManyEditHelper {
                    print( "updated relation  \(paramHelper.name) to \(paramHelper.value())")
                    if let connectManyrelation:ConnectManyRelationProtocol = self.model.connectRelations[paramHelper.name] as? ConnectManyRelationProtocol{
                        connectManyrelation.updateRelation(add: paramHelper.add, remove: paramHelper.remove)
                    }
                }
                else if let paramHelper:EditHelperProtocol = field as? EditHelperProtocol {
                    print( "updated param to \(paramHelper.name) to \(paramHelper.value())")
                    self.model.setValue(paramHelper.value(), forKey: paramHelper.name)
                }
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
        }else {
            self.showDialog(title: "Warning...", message: "There are not changes to save.")
        }
        
    }
    
    private func setTitle(){
        
        if let titleString = self.presenter?.modelTitle(model: self.model!) {
            self.title =  titleString
        }
        else  if let id:Any = self.model?.primaryKeyValue,
            let path:String = self.model?.modelPath{
            self.title =  "\(path)\\\(id)"
        }
    }
    
    private func showResultDialog (){

        self.showDialog(title: "Saved", message: "Changes were Saved",  handler:{(action) in
            if((self.presentingViewController) != nil){
                self.dismiss(animated: true, completion: nil)
            }
        });
    }
    
    private func showErrorDialog (error:Error){
        self.showDialog(title: "Error", message:  error.localizedDescription)
    }
    
    private func showDialog (title:String, message:String, button:String = "ok", handler: ((UIAlertAction) -> Swift.Void)? = nil){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.default, handler: handler))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    public func onFieldChanged(field:EditHelperProtocol) {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let name = editableFieldsName[indexPath.row]
        let field = self.editableFields[name]!
        if let imageUploaded:UploadedImage = field.newValue as? UploadedImage {
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            self.selectedImageEditHelper = field
            present(imagePicker, animated: true, completion: nil)
            
        }
        
    }
    
    //MARK: - ImagePicker delegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image:UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            var field:UploadedFileHelper = self.selectedImageEditHelper as? UploadedFileHelper{
            var newValue = UploadedImage()
            newValue.image = image
            field.newValue = newValue
            self.editableFields[field.name] = field
            self.tableView.reloadData()
        }
        
        self.selectedImageEditHelper = nil
        
        dismiss(animated: true, completion: nil)
    }
    
   
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.selectedImageEditHelper = nil
        dismiss(animated: true, completion: nil)
        
    }

    
    // MARK: - Navigation
    
    func onItemsSelected(selected:Array<ConnectModel>, selectionMetaData:Any) {
        
        if var field:EditHelper = selectionMetaData as? EditHelper,
            let selectedModel = selected.first,
            let relation:ConnectOneRelationProtocol = self.model.connectRelations[field.name] as? ConnectOneRelationProtocol {
           // relation.setObject(model: selectedModel)
           field.newValue = selectedModel
           self.editableFields[field.name] = field
           self.tableView.reloadData()
        }
        
        if var field:ManyEditHelper = selectionMetaData as? ManyEditHelper {
            self.editableFields[field.name] = field
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = self.tableView.indexPathForSelectedRow
        let name:String = self.editableFieldsName[(indexPath?.row)!]
        let segueIdentifier:String = segue.identifier != nil ? segue.identifier! : ""
        let field = self.editableFields[name]
        
        if ("SelectSingleSegue".elementsEqual(segueIdentifier)) {
            
            if let controller:ModelListTableViewController = segue.destination as? ModelListTableViewController, let relation:ConnectOneRelationProtocol = self.model.connectRelations[name] as? ConnectOneRelationProtocol {
                controller.mode = .SingleSelect
                controller.modelListDelegate = self
                controller.selectionMetaData = field
                controller.list = relation.relatedType.list()
            }
        }
        else if ("SelectManySegue".elementsEqual(segueIdentifier)) {
            
            if let controller:EditManyRelationNavigationController = segue.destination as? EditManyRelationNavigationController, let relation:ConnectManyRelationProtocol = self.model.connectRelations[name] as? ConnectManyRelationProtocol {
                controller.relation = relation
                controller.modelListDelegate = self
                controller.selectionMetaData = field
                
            }
        }
       

        //OneRelationSegue
        
    }
    
}
