//
//  StaticCellsTestTableViewController.swift
//  Test
//
//  Created by Alexandre on 12/02/15.
//  Copyright (c) 2015 ACT Productions. All rights reserved.
//

import UIKit
import SwiftUtils

class StaticCellsTestTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44 // Set to "average" cell height (it can be pretty much any reasonable number). Very important or cell sizing won't work!
    }
        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as DatePickerTableViewCell
        cell.toggleExpandedAnimated()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as DatePickerTableViewCell
        
        cell.leftLabel.text = "Left label text jhjkhgkjhg"
        cell.rightLabel.text = "Right label text"
        cell.collapsedHeight = 60 // Setting property here does not require calling "reloadTableViewHeight" because once you return the cell the tableView will acknowledge its height
        
        cell.collapseOtherCellsWhenExpanding = indexPath.row != 0
        
        cell.dateChanged = { cell in
            println("\(indexPath.row): \(cell.date)")
        }
        
        return cell
    }
    
    @IBAction func collapse() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as DatePickerTableViewCell
        
        // If you set any property on the cell that changes the height of the cell, it is necessary to call "reloadTableViewHeight" for the cell to change to the new height
        cell.collapsedHeight = cell.collapsedHeight == nil ? 100 : nil
        cell.reloadHeightForTableView(animate: true)
    }
}
