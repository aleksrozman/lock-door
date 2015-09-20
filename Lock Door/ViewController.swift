//
//  ViewController.swift
//  Lock Door
//
//  Created by Aleks R on 9/19/15.
//  Copyright © 2015 Aleks R. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    /// The photon device pointer
    var photon: Photon?
    
    /// The subview
    var status: StatusController?

    /// Handle the exit button
    ///
    /// - parameter sender: sender
    /// - returns: nothing
    @IBAction func exitButton(sender: AnyObject) {
        leaveView()
    }
    
    /// Handle the open button
    ///
    /// - parameter sender: sender
    /// - returns: nothing
    @IBAction func openButton(sender: AnyObject) {
        photon?.open({() in self.status?.closeSwitch(false)})
    }
    
    /// Handle the close button (external for the subview)
    ///
    /// - parameter sender: sender
    /// - returns: nothing
    func closeButton(sender: AnyObject) {
        photon?.close({() in self.status?.closeSwitch(true)})
    }
    
    /// Popup an alert message and offer the settings button
    ///
    /// - parameters:
    ///     - message: What message to show
    ///     - action: Action label
    ///     - handler: What to do when the action is launched
    /// - returns: nothing
    func showAlert(message: String, action: String = "Settings", handler: (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: handler))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /// Open the settings panel based on the error input
    ///
    /// - parameter type: error type that requires settings to fix
    /// - returns: nothing
    func launchSettings(type: Int) {
        switch(type)
        {
        case 0, 1: // FIXME remove the hard codeing
            showAlert("Login failure", handler: {(UIAlertAction) in
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(settingsUrl!)
            })
        default:
            showAlert("Device missing", handler: {(UIAlertAction) in
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(settingsUrl!)
            })
        }
    }
    
    /// Log into the device and verify it can work
    /// otherwise popup the settings to try again
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let username = userDefaults.stringForKey("particleUsername"),
            let password = userDefaults.stringForKey("particlePassword"),
            let device = userDefaults.stringForKey("particleDevice") {
                photon = Photon(username: username, password: password, device: device)
                photon?.login({() in
                    self.getStatus(userDefaults.boolForKey("lockLaunch"))
                    }, failure: launchSettings)
        }
        else
        {
            launchSettings(0)
        }
        super.viewDidAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "statusView") {
            status = segue.destinationViewController as? StatusController;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Get the status of all switches in the subview
    ///
    /// - parameter lockLaunch: optional lock and exit if not closed
    /// - returns: 0 always
    func getStatus(lockLaunch: Bool = false) -> Int
    {
        self.photon?.closed({(val: Bool) in
            let closeStatus = val
            self.status?.closeSwitch(val)
            self.photon?.front({(val: Bool) in
                self.status?.frontSwitch(val)
                self.photon?.screen({(val: Bool) in
                    self.status?.screenSwitch(val)
                    if lockLaunch {
                        self.photon?.close({() in
                            if !closeStatus {
                                self.leaveView()
                            }
                        })
                    }
                })
            })
        })
        return 0
    }
    
    /// Cleanup and exit
    ///
    /// - parameter void
    /// - returns: nothing
    func leaveView() {
        photon?.logoff()
        // ??? exit kills everything even the logoff mid-execution, also not apple friendly
        exit(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

