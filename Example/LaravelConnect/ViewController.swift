//
//  ViewController.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 11/19/2017.
//  Copyright (c) 2017 Roberto Prato. All rights reserved.
//

import UIKit
import LaravelConnect

class ViewController: UIViewController {

    private var browserStoryBoard: UIStoryboard?
    private var sortByName: Sort!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sortByName = Sort()
        self.sortByName.add(field: "name", order: .ASC)
        
        self.browserStoryBoard = LaravelConnect.storyBoard()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onShowCities(_ sender: Any) {
  
        guard let vc:ModelNavigationController = self.browserStoryBoard?
            .instantiateInitialViewController() as! ModelNavigationController else {return}
   

        
        vc.list = City.list()
            .clone(newFilter: nil, newSort: self.sortByName )
        
        self.show(vc, sender: self)
    }
    
    @IBAction func onShowCountries(_ sender: Any) {
        
        guard let vc:ModelNavigationController = self.browserStoryBoard?
            .instantiateInitialViewController() as! ModelNavigationController else {return}
        

        vc.list = Country.list().clone(newFilter: nil, newSort: self.sortByName )
        self.show(vc, sender: self)
    }
    
    @IBAction func onShowUsers(_ sender: Any) {
        
        guard let vc:ModelNavigationController = self.browserStoryBoard?
            .instantiateInitialViewController() as! ModelNavigationController else {return}
        

        vc.list = User.list().clone(newFilter: nil, newSort: self.sortByName )
        self.show(vc, sender: self)
    }
    
}

