//
//  DatePickerTableViewCell.swift
//

import UIKit

public class DatePickerTableViewCell: ExpandableTableViewCell {
    
    public var dateChanged: ((cell: DatePickerTableViewCell) -> ())?
    public var dateFormatter: ((cell: DatePickerTableViewCell, date: NSDate) -> String) = { cell, date in
        let df = NSDateFormatter()
        df.dateStyle = .ShortStyle
        df.timeStyle = .ShortStyle
        return df.stringFromDate(date)
    }
    
    public var date: NSDate = NSDate() {
        didSet {
            datePicker.date = date
            rightLabel.text = dateFormatter(cell: self, date: date)
        }
    }
    
    public let datePicker = UIDatePicker()
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareDatePicker()
    }
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareDatePicker()
    }
    
    private func prepareDatePicker() {
        datePicker.addTarget(self, action: "datePicked", forControlEvents: .ValueChanged)
        embeddedView = datePicker
    }
    func datePicked() {
        date = datePicker.date
        dateChanged?(cell: self)
    }
}
