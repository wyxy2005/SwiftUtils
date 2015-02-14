//
//  ExpandableTableViewCell.swift
//

import UIKit
import Cartography

private let ExpandableTableViewCellDidExpandNotification = "ExpandableTableViewCellDidExpandNotification"

private let standardTableViewAnimationTime = 0.3
private let defaultLabelPadding = CGSize(width: 15, height: 12)
private let highlightedBackgroundColor = UIColor(white: 0.8314, alpha: 1)
private let rightLabelCollapsedTextColor = UIColor(hue: 0.639, saturation: 0.041, brightness: 0.576, alpha: 1.0)

public class ExpandableTableViewCell: UITableViewCell {
    
    // MARK: - Public vars
    public var collapseOtherCellsWhenExpanding = true

    public let leftLabel = UILabel()
    public let rightLabel = UILabel()
    
    public var embeddedView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            embeddedViewConstraintGroup = nil
            
            if let view = embeddedView {
                embeddedViewContainer.addSubview(view)
                setNeedsUpdateConstraints()
            }
        }
    }
    
    public var collapsedHeight: CGFloat? {
        didSet {
            if let height = collapsedHeight {
                if let c = labelsContainerHeightConstraint { c.constant = height }
                else { setNeedsUpdateConstraints() }
            }
            else {
                if let c = labelsContainerHeightConstraint { labelsContainer.removeConstraint(c) }
                labelsContainerHeightConstraint = nil
            }
        }
    }
    
    public var labelPadding: CGSize = defaultLabelPadding {
        didSet {
            if let group = labelsConstraintGroup {
                constrain(self, replace: group) { v in return }
                labelsConstraintGroup = nil
            }
            
            setNeedsUpdateConstraints()
        }
    }
    
    // MARK: - Public methods
    
    public func reloadHeightForTableView(#animate: Bool) {
        if animate {
            UIView.animateWithDuration(standardTableViewAnimationTime, animations: contentView.layoutIfNeeded)
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }
        else {
            contentView.layoutIfNeeded()
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    public func toggleExpandedAnimated() {
        tableView?.beginUpdates()
        
        if !expanded && collapseOtherCellsWhenExpanding { NSNotificationCenter.defaultCenter().postNotificationName(ExpandableTableViewCellDidExpandNotification, object: self) }
        expand(!expanded, animate: true)
        
        tableView?.endUpdates()
    }
    public func expandAnimated() {
        if !expanded { toggleExpandedAnimated() }
    }
    public func collapseAnimated() {
        if expanded { toggleExpandedAnimated() }
    }
    
    public func setExpanded(expanded: Bool, animate: Bool) {
        if animate {
            if self.expanded != expanded { toggleExpandedAnimated() }
        }
        else {
            expand(expanded, animate: false)
        }
    }
    
    // MARK: - Private vars
    public private(set) var expanded: Bool = false
    
    private let separator = UIView()
    private let labelsContainer = UIView()
    private let embeddedViewContainer = UIView()
    
    private var baseConstraintGroup: ConstraintGroup?
    private var labelsConstraintGroup: ConstraintGroup?
    private var embeddedViewConstraintGroup: ConstraintGroup?
    private var expansionConstraint: NSLayoutConstraint?
    private var labelsContainerHeightConstraint: NSLayoutConstraint?
    
    private var cellExpandedNotification: NSObjectProtocol?

    private var tableView: UITableView? {
        var view = superview
        while view != nil {
            if let tableView = view as? UITableView { return tableView }
            view = view?.superview
        }
        return nil
    }
    
    // MARK: - Layout & other private functions
    public override func updateConstraints() {
        if baseConstraintGroup == nil {
            baseConstraintGroup = constrain(labelsContainer, embeddedViewContainer, contentView) { v1, v2, s in
                v1.left == s.left
                v1.right == s.right
                v1.top == s.top
                
                // Priority < 1000 to avoid problems with "UIView-Encapsulated-Layout-Height"
                v2.top == v1.bottom ~ 999
                
                v2.left == s.left
                v2.right == s.right
                v2.bottom == s.bottom
            }
            
            constrain(separator, embeddedViewContainer) { v1, s in
                v1.top == s.top
                v1.left == s.left
                v1.right == s.right
                v1.height == 0.5
            }
        }
        
        if labelsConstraintGroup == nil {
            labelsConstraintGroup = constrain(leftLabel, rightLabel, labelsContainer) { v1, v2, s in
                v1.left == s.left + self.labelPadding.width
                v1.top == s.top + self.labelPadding.height
                v1.bottom == s.bottom - self.labelPadding.height
                
                // Priority < 1000 to avoid problems with "UIView-Encapsulated-Layout-Width"
                v1.right == v2.left - self.labelPadding.width ~ 999
                
                v2.right == s.right - self.labelPadding.width
                v2.top == s.top + self.labelPadding.height
                v2.bottom == s.bottom - self.labelPadding.height
            }
        }
        
        if expansionConstraint == nil {
            if embeddedView != nil && expanded {
                constrain(embeddedView!, embeddedViewContainer) { v, s in
                    self.expansionConstraint = (s.bottom == v.bottom)
                }
            }
            else {
                constrain(embeddedViewContainer) { v in
                    self.expansionConstraint = (v.bottom == v.top)
                }
            }
        }
        
        if let height = collapsedHeight {
            if labelsContainerHeightConstraint == nil {
                constrain(labelsContainer) { self.labelsContainerHeightConstraint = $0.height == height }
            }
        }
        
        if let view = embeddedView {
            if embeddedViewConstraintGroup == nil {
                constrain(view, embeddedViewContainer) { v1, s in
                    v1.left == s.left
                    v1.right == s.right
                    v1.top == s.top
                }
            }
        }
        
        super.updateConstraints()
    }
    private func setupViews() {
        // View hierarchy
        for view in [labelsContainer, embeddedViewContainer] { contentView.addSubview(view) }
        for view in [leftLabel, rightLabel] { labelsContainer.addSubview(view) }
        
        embeddedViewContainer.addSubview(separator)
        setNeedsUpdateConstraints()
        
        // View properties
        leftLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        rightLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        rightLabel.textColor = rightLabelCollapsedTextColor
        
        leftLabel.setContentCompressionResistancePriority(998, forAxis: .Horizontal)
        rightLabel.setContentHuggingPriority(998, forAxis: .Horizontal)
        
        separator.backgroundColor = UIColor(white: 0, alpha: 0.1)
        embeddedViewContainer.clipsToBounds = true
        
        // Notifications
        cellExpandedNotification = NSNotificationCenter.defaultCenter().addObserverForName(ExpandableTableViewCellDidExpandNotification, object: nil, queue: NSOperationQueue.mainQueue()) { n in
            let cell = n.object as ExpandableTableViewCell
            
            if cell != self && cell.tableView != nil && cell.tableView == self.tableView {
                self.setExpanded(false, animate: true)
            }
        }
        
        // Start collapsed by default
        expanded = false
        embeddedViewContainer.alpha = 0
        
        // Set text styles
        DynamicTypeManager.watch(leftLabel, textStyle: UIFontTextStyleBody)
        DynamicTypeManager.watch(rightLabel, textStyle: UIFontTextStyleBody)
    }
    
    private func expand(expand: Bool, animate: Bool) {
        expanded = expand
        
        if let c = expansionConstraint { embeddedViewContainer.removeConstraint(c) }
        expansionConstraint = nil
        setNeedsUpdateConstraints()
        
        let animation1: ()->() = {
            self.rightLabel.textColor = self.expanded ? self.tintColor : rightLabelCollapsedTextColor
        }
        let animation2: ()->() = {
            self.contentView.layoutIfNeeded()
        }
        let completion: (Bool)->() = { finished in
            if finished && !self.expanded { self.embeddedViewContainer.alpha = 0 }
        }
        
        if expanded { embeddedViewContainer.alpha = 1 }
        if animate {
            UIView.transitionWithView(rightLabel, duration: standardTableViewAnimationTime, options: .TransitionCrossDissolve, animations: animation1, completion: completion)
            UIView.animateWithDuration(standardTableViewAnimationTime, animations: animation2)
        }
        else {
            animation1()
            animation2()
            completion(true)
        }
    }
    
    // MARK: - Other methods
    public override func prepareForReuse() {
        super.prepareForReuse()
        // Having this here hurts performance considerably
        // This setup has to be done by the user of the cell in
        // tableView(tableView, cellForRowAtIndexPath)
        // (that way performance is much better)
        
        /*leftLabel.text = ""
        rightLabel.text = ""
        collapsedHeight = nil
        labelPadding = defaultLabelPadding
        collapseOtherCellsWhenExpanding = true
        labelsContainer.backgroundColor = UIColor.clearColor()*/
    }
    public override func setHighlighted(highlighted: Bool, animated: Bool) {
        UIView.animateWithDuration(0.1, animations: { self.labelsContainer.backgroundColor = highlighted ? highlightedBackgroundColor : UIColor.clearColor() } )
    }
    public override func setSelected(selected: Bool, animated: Bool) {
        UIView.animateWithDuration(0.1, animations: { self.labelsContainer.backgroundColor = selected ? highlightedBackgroundColor : UIColor.clearColor() } )
    }
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
}
