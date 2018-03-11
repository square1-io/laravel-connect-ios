//
//  EditManyRelationViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 11/03/2018.
//

import UIKit

class EditManyRelationNavigationController: UINavigationController {
    
    public var modelListDelegate:ModelListTableViewDelegate!
    public var relation:ConnectManyRelationProtocol!
    public var selectionMetaData:EditHelper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let controller:EditManyRelationViewController = self.childViewControllers.first as? EditManyRelationViewController {
            controller.modelListDelegate = modelListDelegate
            controller.relation = relation
            controller.selectionMetaData = selectionMetaData
        }
        
    }
    
}

class EditManyRelationViewController: UITabBarController {

    public var modelListDelegate:ModelListTableViewDelegate!
    public var relation:ConnectManyRelationProtocol!
    public var selectionMetaData:EditHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add/Remove \(self.relation.name)"
      
        //setup the add tab with the items from the related class
        if let addTableViewController:ModelListTableViewController = self.viewControllers?.first as? ModelListTableViewController {
            addTableViewController.mode = .MultiSelect
            addTableViewController.list = relation.relatedType.list()
            addTableViewController.selectionMetaData = self.selectionMetaData
            addTableViewController.modelListDelegate = self.modelListDelegate
        }
        
       //setup the remove tab with the items in the relation
       if let addTableViewController:ModelListTableViewController = self.viewControllers?.last as? ModelListTableViewController {
            addTableViewController.mode = .MultiSelect
            addTableViewController.list = relation.list()
            addTableViewController.selectionMetaData = self.selectionMetaData
            addTableViewController.modelListDelegate = self.modelListDelegate
        }
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
