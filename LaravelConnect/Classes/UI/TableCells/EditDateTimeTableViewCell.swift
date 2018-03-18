//
//  EditDateTimeTableViewCell.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 16/03/2018.
//

import UIKit

class EditDateTimeTableViewCell: BaseEditTableViewCell {

    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelValue: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var timePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func dateSelected() {
        let date = combineDateAndTime()
        self.field.newValue = date
        displayDateAndTime(date: date)
        notifyUpdate()
    }
    
    @IBAction func timeSelected() {
        let date = combineDateAndTime()
        self.field.newValue = date
        displayDateAndTime(date: date)
        notifyUpdate()
    }
    override  func setEditableField(editable:EditHelperProtocol){
        super.setEditableField(editable: editable)
        
        self.labelName.text = editable.name
        
        if let date:NSDate = editable.newValue as? NSDate {
            self.labelValue.text = String(describing:date)
            self.datePicker.date = date as Date
            self.timePicker.date = date as Date
        }
    }
    
    private func combineDateAndTime() -> Date? {
        
        let dateUnitFlags = Set<Calendar.Component>([.day, .month, .year])
        let date = Calendar.current.dateComponents(dateUnitFlags, from: self.datePicker.date)
  
        let timeUnitFlags = Set<Calendar.Component>([.hour, .minute])
        let time = Calendar.current.dateComponents(timeUnitFlags, from: self.timePicker.date)

        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = date.year
        dateComponents.month = date.month
        dateComponents.day = date.day
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let newDate = userCalendar.date(from: dateComponents)
        
        return newDate
        
    }
    
    private func displayDateAndTime(date:Date?) {
        
        if let date = date {
            self.labelValue.text = String(describing:date)
            self.datePicker.date = date as Date
            self.timePicker.date = date as Date
        }else {
            self.labelValue.text = "Not set"
        }
    }

}
