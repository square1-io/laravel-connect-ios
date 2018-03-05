//
//  ModelNavigationController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 04/02/2018.
//

import UIKit
import CoreData

public class ModelOptionsNavigationController: UINavigationController {

    public var list:ModelList?
    public var listDelegate:ModelListOptionsDelegate?
    public var searchableAttributes:[String:NSAttributeDescription]!
    public var selectedSearchableAttributes:[String:NSAttributeDescription]!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        loadInitialList()
        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadInitialList(){
        if let controller:ModelListOptionsTableViewController = self.childViewControllers.first as? ModelListOptionsTableViewController {
            controller.listDelegate = self.listDelegate
            controller.initialList = self.list
            controller.selectedSearchableAttributes = self.selectedSearchableAttributes
            controller.searchableAttributes = self.searchableAttributes
        }
    }
    

}
