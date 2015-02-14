//
//  Segue Manager.swift
//

// Note: adapted from http://tomlokhorst.tumblr.com/post/104358251649/easy-storyboard-segues-in-swift

import UIKit

/**
Added as a constant property on view controllers:

`class ExampleViewController: UIViewController {
    let segueManager = SegueManager()

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segueManager.prepare(segue)
    }
}`
*/
public class SegueManager {
    public typealias SeguePreparationBlock = UIStoryboardSegue -> Void
    public init() {}
    
    private var blocks = [String: SeguePreparationBlock]()
    
    /**
    Save a preparation block for later use. This is useful when segues aren't triggered using perform(id:,viewController:) but instead come directly from storyboards
    
    :param: id The segue to associate the block to
    :param: preparation The block to run when preparing for the segue
    */
    public subscript(id: SegueID) -> SeguePreparationBlock? {
        get { return blocks[id.key] }
        set { blocks[id.key] = newValue }
    }
    
    /**
    Perform a segue
    
    :param: id The segue to perform
    :param: viewController The view controller that is performing the segue
    :param: preparation The block to run when preparing for the segue
    */
    public func perform(id: SegueID, _ viewController: UIViewController, _ preparation: SeguePreparationBlock) {
        blocks[id.key] = preparation
        viewController.performSegueWithIdentifier(id.key, sender: viewController)
    }
    
    /**
    Perform a segue
    
    :param: id The segue to perform
    :param: viewController The view controller that is performing the segue
    */
    public func perform(id: SegueID, _ viewController: UIViewController) {
        viewController.performSegueWithIdentifier(id.key, sender: viewController)
    }
    
    /**
    Should be called only when prepareForSegue(segue:, sender:) is called on the view controller
    */
    public func prepare(segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            if let prep = blocks[id] {
                prep(segue)
            }
        }
    }
}

/**
Represents one segue key. SegueID keys should be added as a private extension to this struct next to each view controller that uses them:

private extension SegueID {
    static let Segue1 = SegueID("Segue1")
}

Adding keys as an extension allows for quick usage:

mySegueManager[.Segue1] = ...
*/
public struct SegueID {
    public let key: String
    public init(_ k: String) { key = k }
}