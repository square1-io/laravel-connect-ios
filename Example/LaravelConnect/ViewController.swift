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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        var info = ModelInfo(modelType:City.self,
                             modelTitle:{(model) in
                                let city = model as! City
                                return city.name},
                             modelSubtitle:{(model) in
                                let city = model as! City
                                return city.localName})
        vc.modelInfo = info
        self.show(vc, sender: self)
    }
    
    @IBAction func onShowCountries(_ sender: Any) {
        
        guard let vc:ModelNavigationController = self.browserStoryBoard?
            .instantiateInitialViewController() as! ModelNavigationController else {return}
        
        let info = ModelInfo(modelType:Country.self,
                             modelTitle:{(model) in
                                let country = model as! Country
                                return country.name},
                             modelSubtitle:{(model) in
                                let country = model as! Country
                                return country.code})
        vc.modelInfo = info
        self.show(vc, sender: self)
    }
    
    @IBAction func onShowUsers(_ sender: Any) {
        
        guard let vc:ModelNavigationController = self.browserStoryBoard?
            .instantiateInitialViewController() as! ModelNavigationController else {return}
        
        let info = ModelInfo(modelType:User.self,
                             modelTitle:{(model) in
                                let u = model as! User
                                return u.name},
                             modelSubtitle:{(model) in
                                let u = model as! User
                                return u.email})
        vc.modelInfo = info
        self.show(vc, sender: self)
    }
    
}

