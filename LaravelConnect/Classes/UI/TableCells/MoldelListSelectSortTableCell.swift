//
//  MoldelListSelectSortTableCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 10/02/2018.
//

import Foundation
import CoreData

public class MoldelListSelectSortTableCell : UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBOutlet var sortOptionPicker: UIPickerView!
    
    @IBOutlet var sortOrderSegmentedControl: UISegmentedControl!
    
    weak  var optionsController:ModelListOptionsTableViewController?
    
    private var needsSetup: Bool?
    private var sortingFields: Array<String>?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.needsSetup = true
        self.sortOptionPicker.dataSource = self
        sortOrderSegmentedControl.addTarget(self, action: #selector(orderUpdated),
                                            for: UIControlEvents.valueChanged)
    }
    
    
   @objc private func orderUpdated(sender:Any?){
    let selected:SortOption.Order = sortOrderSegmentedControl.selectedSegmentIndex == 0 ? SortOption.Order.ASC : SortOption.Order.DESC
    if let fields = self.sortingFields,
        let index:Int = self.sortOptionPicker.selectedRow(inComponent: 0),
        let field:String = fields[index],
        let attribute:NSAttributeDescription = self.optionsController?.sortingOptions()[field],
        let jsonKey:String = attribute.jsonKey{
        optionsController?.sortOrderChanged(field: jsonKey, order: selected)
    }

    }
    
    func getpropertyNameFromJsonKeyName(jsonKey:String) -> String{
        
        
        let options:[String:NSAttributeDescription] = (self.optionsController?.sortingOptions())!
        
        for (n,a) in options {
            if (jsonKey.elementsEqual(a.jsonKey)){
                return n
            }
        }
        
        return ""
        
    }
    
    func initialSetup(tableController:ModelListOptionsTableViewController) {
        
        if(self.needsSetup == true) {

            self.optionsController = tableController
            self.sortingFields = Array(tableController.sortingOptions().keys)
            self.sortOptionPicker.delegate = self
            self.needsSetup = false
            
            if let initialList = tableController.initialList,
                let first = initialList.sort.firstOption,
                let pName:String = self.getpropertyNameFromJsonKeyName(jsonKey: first.field),
                let selectedIndex = self.sortingFields?.index(of: pName) {
               self.sortOptionPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
                self.sortOrderSegmentedControl.selectedSegmentIndex = first.order == .ASC ? 0 : 1
            }
        }
        
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let f = self.sortingFields {
            return f.count
        }
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if let f = self.sortingFields {
            return f[row]
        }
        
        return  ""
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.orderUpdated(sender: pickerView)
    }
    
}
