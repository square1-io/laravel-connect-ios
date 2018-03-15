//
//  ModelDetailsTableViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 05/02/2018.
//

import UIKit
import CoreData
import SafariServices

private let ATTRIBUTES_LABEL = "Attributes"
private let ONE_LABEL = "One Relations"
private let MANY_LABEL = "Many Relations"

class ModelDetailsTableViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    public var model:ConnectModel!
    public var modelId:Any?
    public var modelType:ConnectModel.Type?
    private var presenter:ModelPresenter?
    
    public var sections:Array<[String]>?
    public var sectionsNames:Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let control = UIRefreshControl()
        control.backgroundColor = UIColor.lightGray
        control.tintColor = UIColor.darkGray
        control.addTarget(self,action: #selector(refreshModel), for: UIControlEvents.valueChanged)

        self.refreshControl = control
        
        var sec = Array<[String]>()
        var secNames = Array<String>()
        
        if let keys = self.model?.attributes.keys,
                keys.count > 0 {
             var attr = Array(keys)
             attr.sort()
             sec.append(attr)
             secNames.append(ATTRIBUTES_LABEL)
        }
        
        if let keys = self.model?.oneRelations.keys,
                keys.count > 0 {
            var ones = Array(keys)
            ones.sort()
            sec.append(ones)
            secNames.append(ONE_LABEL)
        }
        
        if let keys = self.model?.manyRelations.keys,
                keys.count > 0 {
            var manys = Array(keys)
            manys.sort()
            sec.append(manys)
            secNames.append(MANY_LABEL)
        }
        
        self.sections = sec
        self.sectionsNames = secNames
        if let className = self.model?.className{
            self.presenter = LaravelConnect.shared().presenterForClass(className: className)
        }
        self.setTitle()
        
        self.loadModel(userInitiated: false)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let rightButtonItem = UIBarButtonItem.init(
            title: "Edit",
            style: .done,
            target: self,
            action: #selector(editButtonAction(sender:))
        )
        
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.model.reloadFromContext()
        self.setTitle()
        self.tableView.reloadData()
    }
    
    @objc private func editButtonAction(sender:Any) {
        performSegue(withIdentifier: "EditSegue", sender: nil)
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
    
    
    @objc private func refreshModel(){
        self.loadModel(userInitiated: true)
    }
    
    
    private func loadModel(userInitiated:Bool) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if(userInitiated){
         self.refreshControl?.beginRefreshing()
        }
        
        self.model?.refresh(done: { (managedId, error) in
            self.setTitle()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
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
            cell = self.setAttributeCell(tableView: tableView, indexPath: indexPath)
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
    
    private func setAttributeCell(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {

        var cell:UITableViewCell!
        
        if let sec = self.sections,
            let secIndex:Int = indexPath.section,
            let attributes:[String] = sec[secIndex],
            let name:String = attributes[indexPath.row]{
            
            let value = self.model.value(forKey: name)
            
            if let image:UploadedImage = value as? UploadedImage {
                cell = self.setupUploadedImageAttributeCell(tableView: tableView, indexPath: indexPath, name: name, value: image)
            }else {
                cell = self.setupStringAttributeCell(tableView: tableView, indexPath:indexPath, name: name, value: value)
            }
        }
        
        return cell
    }

    private func setupUploadedImageAttributeCell(tableView:UITableView, indexPath:IndexPath, name:String, value:UploadedImage) -> UITableViewCell {
        
        let cell:ModelUploadedFileCell = tableView.dequeueReusableCell(withIdentifier: "ModelUploadedFileCell", for: indexPath) as! ModelUploadedFileCell
        
            cell.labelType.text =  "uploaded image"
        
            cell.labelName.text = name
            if let url = value.imageUrl {
                cell.labelValue.text = String( describing: url )
                cell.url = url
                cell.labelValue.textColor = UIColor.black
            }else {
                cell.labelValue.text = "not set"
                cell.url = nil
                cell.labelValue.textColor = UIColor.lightGray
            }
        
        
        return cell
    }
    
    private func setupStringAttributeCell(tableView:UITableView, indexPath:IndexPath, name:String, value:Any?) -> UITableViewCell {
        
        let cell:ModelAttributeCell = tableView.dequeueReusableCell(withIdentifier: "ModelAttributeCell", for: indexPath) as! ModelAttributeCell
        
        if let attribute = self.model?.attributes[name],
            let type = attribute.attributeValueClassName {
            
          cell.labelType.text = type
            
        }
        
        cell.labelName.text = name
        
        if let v = value  {
            cell.labelValue.text = String( describing: v )
            cell.labelValue.textColor = UIColor.black
        }else {
            cell.labelValue.text = "not set"
            cell.labelValue.textColor = UIColor.lightGray
        }
        
        return cell
    }
    
    //ModelUploadedFileCell
    
    
    private func attributeForIndexPath(indexPath:IndexPath) -> NSAttributeDescription?{
        
        if let sec = self.sections,
            let secIndex:Int = indexPath.section,
            let attributes:[String] = sec[secIndex],
            let name:String = attributes[indexPath.row],
            let attribute = self.model?.attributes[name] {
            
            return attribute
        }
        
        return nil
    }
    
    private func oneRelationForIndexPath(indexPath:IndexPath?) -> ConnectOneRelationProtocol?{
        
        if let sec = self.sections,
            let secIndex:Int = indexPath?.section,
            let attributes:[String] = sec[secIndex],
            let secRow:Int = indexPath?.row,
            let name:String = attributes[secRow],
            let r = self.model?.connectRelations?[name],
            let relation:ConnectOneRelationProtocol = r as? ConnectOneRelationProtocol {
                return relation
            }
        
        return nil
    }

    private func manyRelationForIndexPath(indexPath:IndexPath?) -> ConnectManyRelationProtocol?{
        
        if let sec = self.sections,
            let secIndex:Int = indexPath?.section,
            let attributes:[String] = sec[secIndex],
            let secRow:Int = indexPath?.row,
            let name:String = attributes[secRow],
            let r = self.model?.connectRelations?[name],
            let relation:ConnectManyRelationProtocol = r as? ConnectManyRelationProtocol {
            return relation
        }
        
        return nil
    }
    
    private func setOneRelationCell(cell:OneRelationCell, indexPath:IndexPath){
        
        if let relation:ConnectOneRelationProtocol = self.oneRelationForIndexPath(indexPath: indexPath) {
            cell.labelName.text = relation.name.capitalized
            
            if let value = relation.object(),
                let presenter:ModelPresenter = LaravelConnect.shared().presenterForClass(className: String(describing: relation.relatedType)) {
                
                cell.labelType.text = presenter.modelTitle(model: value)
                cell.labelValue.text = presenter.modelSubtitle(model: value)
            }
            else if let value = relation.relatedId {
                cell.labelType.text = String(describing: relation.relatedType)
                cell.labelValue.text = String( describing: value )
            }

        }
    }
    
    private func setManyRelationCell(cell:ManyRelationCell, indexPath:IndexPath){
        
        if let relation:ConnectManyRelationProtocol = self.manyRelationForIndexPath(indexPath: indexPath) {
            cell.labelName.text = relation.name.capitalized
            cell.labelType.text = String(describing: relation.relatedType)
            cell.labelValue.text = ""
            
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let currentSection = self.sectionsNames![indexPath.section]
        if( ATTRIBUTES_LABEL.elementsEqual(currentSection) == true) {
            
            if let attribute = self.attributeForIndexPath(indexPath: indexPath),
                let m = self.model {
                if(attribute.name.elementsEqual(m.primaryKeyName)) {
                    return false
                }
                
            }
            return true
        }
        
        return false
    }
    

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let sec = self.sections,
            let secIndex:Int = indexPath.section,
            let attributes:[String] = sec[secIndex],
            let name:String = attributes[indexPath.row]{
            
            let value = self.model.value(forKey: name)
            
            if let image:UploadedImage = value as? UploadedImage,
                let url = image.imageUrl {
                
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true, completion: nil)
            }
        }
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
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
        else if ("ManyRelationSegue".elementsEqual(segueIdentifier)) {
            
            if let controller:ModelListTableViewController? = segue.destination as? ModelListTableViewController,
                let model = self.manyRelationForIndexPath(indexPath: indexPath) {
                controller?.navigationItem.leftBarButtonItem = nil
                controller?.list = model.list()
            }
        }
        else if ("EditSegue".elementsEqual(segueIdentifier)) {
            
            if let controller:ModelDetailsEditNavigationController? = segue.destination as? ModelDetailsEditNavigationController,
                let m = self.model{
                controller?.model = m
            }
        }
        //OneRelationSegue
      
    }
    

}
