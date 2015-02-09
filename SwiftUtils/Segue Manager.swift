//
//  Segue Manager.swift
//

import UIKit

public struct SegueID {
    let key: String
    init(_ k: String) { key = k }
}

public class SegueManager {
    public typealias SeguePreparationBlock = UIStoryboardSegue -> Void
    public init() {}
    
    private var blocks = [String: SeguePreparationBlock]()
    
    subscript(id: SegueID) -> SeguePreparationBlock? {
        get { return blocks[id.key] }
        set { blocks[id.key] = newValue }
    }
    
    public func perform(id: SegueID, _ viewController: UIViewController, _ preparation: SeguePreparationBlock) {
        blocks[id.key] = preparation
        viewController.performSegueWithIdentifier(id.key, sender: viewController)
    }
    
    public func perform(id: SegueID, _ viewController: UIViewController) {
        viewController.performSegueWithIdentifier(id.key, sender: viewController)
    }
    
    public func prepare(segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            if let prep = blocks[id] {
                prep(segue)
            }
        }
    }
}

/* Usage:

private extension SegueID {
    static let MyStoryboardSegue = SegueID("MyStoryboardSegue")
    static let MyProgramaticSegue = SegueID("MyProgramaticSegue")
}

class ExampleViewController: UIViewController {
    let segueManager = SegueManager()
    
    override func viewDidLoad() {
        
        // For when segues aren't activated in code, but in the storyboard
        // For example, segues originating from items on a table view
        segueManager[.MyStoryboardSegue] = { segue in
            // Do something here
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Call the segue manager to tell it a segue is happening.
        // Very important, don't forget this part!
        segueManager.prepare(segue)
    }
    
    func someFunction() {
        // Perform a segue, passing in a closure to be called when the segue is happening.
        segueManager.perform(.MyProgramaticSegue, self) { segue in
            
            // Now do something to the destination view controller, like setting a view model
            let vc = segue.destinationViewController as MyViewController
            vc.viewModel = myViewModel
        }
    }
}

*/