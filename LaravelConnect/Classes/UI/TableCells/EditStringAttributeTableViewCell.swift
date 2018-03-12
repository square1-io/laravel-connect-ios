//
//  EditStringAttributeTableViewCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 21/02/2018.
//

import UIKit

class EditStringAttributeTableViewCell: BaseEditTableViewCell, UITextViewDelegate {

    @IBOutlet var labelName: UILabel!
    
    @IBOutlet var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


     public func textViewDidChange(_ textView: UITextView){
        
        if let s = textView.text {
            self.field.newValue = s
        }
        notifyUpdate()
    }
    
    override func setEditableField(editable: EditHelperProtocol) {
        super.setEditableField(editable: editable)
        self.labelName.text = editable.name
        self.textView.text = String(describing:editable.value())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
