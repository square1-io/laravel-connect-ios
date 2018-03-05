//
//  ModelNavigationController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 04/02/2018.
//

import UIKit

public class ModelNavigationController: UINavigationController {

    public var list:ModelList?
    
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
        if let controller:ModelListTableViewController = self.childViewControllers.first as? ModelListTableViewController {
            controller.list = self.list
        }
    }
    

}
