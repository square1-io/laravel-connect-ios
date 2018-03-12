//
//  EditStringAttributeTableViewCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 21/02/2018.
//

import UIKit

class EditManyRelationTableViewCell: BaseEditTableViewCell {

    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelValue: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if let s = textField.text {
            let d = (s as NSString).doubleValue
            self.field.newValue = NSNumber(value: d)
        }
        notifyUpdate()
    }
    
    override func setEditableField(editable: EditHelperProtocol) {
        super.setEditableField(editable: editable)
        self.labelName.text = editable.name
        self.labelValue.text = String(describing:editable.value())
    }
    


}
