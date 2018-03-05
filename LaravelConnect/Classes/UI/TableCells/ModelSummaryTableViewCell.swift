//
//  ModelSummaryTableViewCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 01/03/2018.
//

import UIKit

class ModelSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet var labelMain: UILabel!
    @IBOutlet var labelSubText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
