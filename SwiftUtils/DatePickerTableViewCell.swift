//
//  DatePickerTableViewCell.swift
//

import UIKit
import Cartography

public class DynamicTypeLabel: UILabel {
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    override init() {
        super.init()
        prepare()
    }
    
    private var notification: NSObjectProtocol?
    private func prepare() {
        // For some reason setting this here without delay has no effect
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue()) {
            self.font = UIFont.preferredFontForTextStyle(self.textStyle)
        }
        
        notification = NSNotificationCenter.defaultCenter().addObserverForName(UIContentSizeCategoryDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self] _ in
            self.font = UIFont.preferredFontForTextStyle(self.textStyle)
            self.invalidateIntrinsicContentSize()
        }
    }
    
    public var textStyle: String = UIFontTextStyleBody {
        didSet { font = UIFont.preferredFontForTextStyle(textStyle) }
    }
}

let DatePickerTableViewCellDidExpandNotification = "DatePickerTableViewCellDidExpandNotification"

public class DatePickerTableViewCell: UITableViewCell {
    
    public var dateChanged: ((cell: DatePickerTableViewCell)->())?
    public var dateFormatter: ((cell: DatePickerTableViewCell, date: NSDate)->String) = { cell, date in
        let df = NSDateFormatter()
        df.dateStyle = NSDateFormatterStyle.ShortStyle
        df.timeStyle = NSDateFormatterStyle.ShortStyle
        return df.stringFromDate(date)
    }
    
    public let leftLabel = DynamicTypeLabel()
    public let rightLabel = DynamicTypeLabel()
    public let datePicker = UIDatePicker()
    
    public var exclusiveExpansion = true
    
    public var date: NSDate = NSDate() {
        didSet {
            datePicker.date = date
            rightLabel.text = dateFormatter(cell: self, date: date)
        }
    }
    
    public var unexpandedHeight: CGFloat {
        get { return collapsedHeightConstraint.constant }
        set { collapsedHeightConstraint.constant = newValue }
    }
    
    public var cellHeight: CGFloat {
        var expandedHeight = unexpandedHeight + CGFloat(datePicker.frame.size.height)
        return expanded ? expandedHeight : unexpandedHeight
    }
    
    public private(set) var expanded: Bool = false
    
    private let rightLabelCollapsedTextColor = UIColor(hue: 0.639, saturation: 0.041, brightness: 0.576, alpha: 1.0)
    private let highlightedBackgroundColor = UIColor(white: 0.8314, alpha: 1)
    
    private let seperator = UIView()
    private let labelsContainer = UIView()
    private let datePickerContainer = UIView()
    
    private var collapsedHeightConstraint: NSLayoutConstraint!
    private var cellExpandedNotification: NSObjectProtocol?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    private func prepare() {
        // Containers
        for view in [labelsContainer, datePickerContainer] {
            contentView.addSubview(view)
        }
        
        constrain(labelsContainer, datePickerContainer, contentView) { v1, v2, s in
            self.collapsedHeightConstraint = (v1.height == 44) // Default value of 44 (can be changed later)
            
            v1.leading == s.leading
            v1.trailing == s.trailing
            v1.top == s.top
            
            // Priority < 1000 to avoid problems with "UIView-Encapsulated-Layout-Height"
            v2.top == v1.bottom ~ 999
            
            v2.leading == s.leading
            v2.trailing == s.trailing
            v2.bottom == s.bottom
        }
        
        // Labels
        for view in [leftLabel, rightLabel] {
            view.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            labelsContainer.addSubview(view)
        }
        
        constrain(leftLabel, rightLabel, labelsContainer) { v1, v2, s in
            v1.leading == s.leading + self.separatorInset.left
            v1.top == s.top
            v1.bottom == s.bottom
            
            // Priority < 1000 to avoid problems with "UIView-Encapsulated-Layout-Width"
            v1.trailing == v2.leading ~ 999
            
            v2.trailing == s.trailing - self.separatorInset.left
            v2.top == s.top
            v2.bottom == s.bottom
        }
        
        leftLabel.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        rightLabel.setContentHuggingPriority(1000, forAxis: .Horizontal)
        rightLabel.textColor = rightLabelCollapsedTextColor
        
        // Date picker
        for view in [datePicker, seperator] {
            datePickerContainer.addSubview(view)
        }
        
        constrain(seperator, datePicker, datePickerContainer) { v1, v2, s in
            v1.top == s.top
            v1.leading == s.leading
            v1.trailing == s.trailing
            v1.height == 0.5
            
            v2.leading == s.leading
            v2.trailing == s.trailing
            v2.centerY == s.centerY
        }
        
        datePickerContainer.clipsToBounds = true
        seperator.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        contentView.layoutIfNeeded()
        
        // Notifications
        cellExpandedNotification = NSNotificationCenter.defaultCenter().addObserverForName(DatePickerTableViewCellDidExpandNotification, object: nil, queue: NSOperationQueue.mainQueue()) { n in
            if n.object as DatePickerTableViewCell != self {
                self.setExpanded(false, animate: true)
            }
        }
        
        // Target-action
        datePicker.addTarget(self, action: "datePicked", forControlEvents: .ValueChanged)
        
        // The default value of false is already set but calling this sets the alpha values as well
        setExpanded(false, animate: false)
    }
    func datePicked() {
        date = datePicker.date
        dateChanged?(cell: self)
    }
    
    public override func setHighlighted(highlighted: Bool, animated: Bool) {
        UIView.animateWithDuration(0.1, animations: { self.labelsContainer.backgroundColor = highlighted ? self.highlightedBackgroundColor : UIColor.clearColor() } )
    }
    public override func setSelected(selected: Bool, animated: Bool) {
        UIView.animateWithDuration(0.1, animations: { self.labelsContainer.backgroundColor = selected ? self.highlightedBackgroundColor : UIColor.clearColor() } )
    }
    
    private func setExpanded(expanded: Bool, animate: Bool) {
        self.expanded = expanded
        
        if expanded {
            datePickerContainer.alpha = 1
        }
        
        let animation: ()->() = {
            self.rightLabel.textColor = self.expanded ? self.tintColor : self.rightLabelCollapsedTextColor
        }
        let completion: (Bool)->() = { finished in
            if finished && !self.expanded { self.datePickerContainer.alpha = 0 }
        }
        
        if animate {
            UIView.transitionWithView(rightLabel, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: animation, completion: completion)
        }
        else {
            animation()
            completion(true)
        }
    }
    
    public func toggleExpanded(#tableView: UITableView) {
        if !expanded && exclusiveExpansion { NSNotificationCenter.defaultCenter().postNotificationName(DatePickerTableViewCellDidExpandNotification, object: self) }
        setExpanded(!expanded, animate: true)
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    public func expand(#tableView: UITableView) {
        if !expanded { toggleExpanded(tableView: tableView) }
    }
    public func collapse(#tableView: UITableView) {
        if expanded { toggleExpanded(tableView: tableView) }
    }
}

