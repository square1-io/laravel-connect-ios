//
//  SelectSearchAttributeTableViewCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 28/02/2018.
//

import UIKit

class SelectSearchAttributeTableViewCell: UITableViewCell {

    @IBOutlet var labelName: UILabel!
    @IBOutlet var switchSelected: UISwitch!
    
    public var controller:ModelListOptionsTableViewController!
    
    @IBAction func selectionChanged(_ sender: Any) {
        controller.onSearchFieldSwitchSelected(sender:self.switchSelected, name: self.labelName.text!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
