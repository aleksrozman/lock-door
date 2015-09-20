//
//  StatusController.swift
//  Lock Door
//
//  Created by Aleks R on 9/20/15.
//  Copyright © 2015 Aleks R. All rights reserved.
//

import UIKit

/// A set of static switches and labels
class StatusController: UITableViewController {

    @IBOutlet weak var closedSwitch: UISwitch!
    @IBOutlet weak var frontdoor: UISwitch!
    @IBOutlet weak var screendoor: UISwitch!
    @IBOutlet var table: UITableView!
    
    /// Tell the parent (which knows the photon) to launch the close
    @IBAction func closeTouch(sender: AnyObject) {
        let parent = parentViewController.self as? ViewController
        parent?.closeButton(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Allow swiping the table to create the refresh effect
    /// clear the switches to show that something is being refreshed
    /// then ask the parent to refresh (since parent knows about the photon)
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        closeSwitch(false)
        frontSwitch(false)
        screenSwitch(false)
        let parent = parentViewController.self as? ViewController
        parent?.getStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Control the close switch
    ///
    /// - parameter val: true = on
    /// - returns: nothing
    func closeSwitch(val: Bool) {
        closedSwitch.setOn(val, animated: true)
    }

    /// Control the front switch
    ///
    /// - parameter val: true = on
    /// - returns: nothing
    func frontSwitch(val: Bool) {
        frontdoor.setOn(!val, animated: true)
    }

    /// Control the screen switch
    ///
    /// - parameter val: true = on
    /// - returns: nothing
    func screenSwitch(val: Bool) {
        screendoor.setOn(!val, animated: true)
    }

}