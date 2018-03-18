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
    public var selectionMetaData:EditHelperProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let controller:EditManyRelationViewController = self.childViewControllers.first as? EditManyRelationViewController,
            let editHelper:ManyEditHelper = self.selectionMetaData as? ManyEditHelper{
            controller.modelListDelegate = modelListDelegate
            controller.relation = relation
            controller.selectionMetaData = editHelper
        }
        
    }
    
}

class EditManyRelationTabController: UIViewController, ModelListTableViewDelegate {
    
    public var modelListDelegate:ModelListTableViewDelegate!
    public var list:ModelList!
    public var selectionMetaData:EditHelperProtocol!
    
    public lazy var selected:Array<ConnectModel> = {
        return Array()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selected = Array()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let segueIdentifier = segue.identifier,
            segueIdentifier.elementsEqual("Embed"), let controller:ModelListTableViewController = segue.destination as? ModelListTableViewController {
           
            controller.mode = .MultiSelect
            controller.list = self.list
            controller.selectionMetaData = self.selectionMetaData
            controller.modelListDelegate = self
            
        }
        
    }
    
  
    
    func onItemsSelected(selected:Array<ConnectModel>, selectionMetaData:Any) {
        if selected.count > 0 {
            self.tabBarItem.badgeValue = "\(selected.count)"
        }else {
            self.tabBarItem.badgeValue = nil
        }
        self.selected = selected
    }
    
    
}

class EditManyRelationViewController: UITabBarController, UITabBarControllerDelegate {


    public var modelListDelegate:ModelListTableViewDelegate!
    public var relation:ConnectManyRelationProtocol!
    public var selectionMetaData:ManyEditHelper!
    
    public var addViewController:EditManyRelationTabController?
    public var removeViewController:EditManyRelationTabController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    
        self.addViewController = self.viewControllers?.first as? EditManyRelationTabController
        self.removeViewController = self.viewControllers?.last as? EditManyRelationTabController
        
        //setup the add tab with the items from the related class
        if self.addViewController != nil {
            self.addViewController?.list = relation.relatedType.list()
            self.addViewController?.selectionMetaData = self.selectionMetaData
            self.addViewController?.modelListDelegate = self.modelListDelegate
        }
        
       //setup the remove tab with the items in the relation
       if self.removeViewController != nil {
            self.removeViewController?.list = relation.list()
            self.removeViewController?.selectionMetaData = self.selectionMetaData
            self.removeViewController?.modelListDelegate = self.modelListDelegate
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateTitle()
    }

    private func updateTitle(){
        
        if let selectedItemTitle = self.tabBar.selectedItem?.title {
            self.title = "\(selectedItemTitle) \(self.relation.name.capitalized)"
        }
        
    
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func save(sender: AnyObject) {

        
        
        if let addController:EditManyRelationTabController = self.addViewController {
            self.selectionMetaData.add = addController.selected
        }
        
        if let removeController:EditManyRelationTabController = self.removeViewController {
            self.selectionMetaData.remove = removeController.selected
        }
        

        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
        }
        
        self.modelListDelegate.onItemsSelected(selected: Array(), selectionMetaData: self.selectionMetaData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.updateTitle()
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        return true
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]){
    
        
        
    }


}
