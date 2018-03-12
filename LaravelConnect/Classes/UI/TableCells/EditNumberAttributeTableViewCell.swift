//
//  EditStringAttributeTableViewCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 21/02/2018.
//

import UIKit

class EditNumberAttributeTableViewCell: BaseEditTableViewCell {

    @IBOutlet var labelName: UILabel!
    
    @IBOutlet var textView: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.textView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        self.textView.text = String(describing:editable.value())
    }
    


}
