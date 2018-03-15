//
//  EditUploadedImageTableViewCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 13/03/2018.
//

import UIKit

class EditUploadedImageTableViewCell: BaseEditTableViewCell {

    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelValue: UILabel!
    
    @IBOutlet var webView: UIWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override  func setEditableField(editable:EditHelperProtocol){
       super.setEditableField(editable: editable)
       
        self.labelName.text = editable.name
        
       if let uploaded:UploadedImage = editable.newValue as? UploadedImage, let url:URL = uploaded.imageUrl {
            self.labelValue.text = String(describing:url)
            self.webView.loadRequest(URLRequest.init(url: url))
        }
    }

}
