//
//  ModelAttributeCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 05/02/2018.
//

import UIKit

class ModelUploadedFileCell: UITableViewCell {

    @IBOutlet var labelName:UILabel!
    @IBOutlet var labelType: UILabel!
    @IBOutlet var labelValue: UILabel!
    
    var url:URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
