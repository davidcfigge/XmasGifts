//
//  GlobalSplitViewController.swift
//  Xmas Gifts
//
//  Created by David Figge on 2/24/17.
//
//  This class subclasses the UISplitViewController. The primary purpose is to ensure that when the app
//  is first started the (default) detail screen (which has no data yet) is not shown, but rather the master view.
//

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self        // Set up ourselves as UISplitViewControllerDelegate so we can get notifications
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        // Make sure that when we are launched (detail view data = nil), we display the master view
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? GiftListViewController else { return false }
        if topAsDetailController.person == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
}
