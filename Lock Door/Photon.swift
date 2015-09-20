//
//  Photon.swift
//  Lock Door
//
//  Created by Aleks R on 9/19/15.
//  Copyright © 2015 Aleks R. All rights reserved.
//

import Foundation

/// Helper class to control everything about the photon/spark device
class Photon {
    var username = ""
    var password = ""
    var device = ""
    var photon : SparkDevice?
    
    /// Initialize the variables to be used by the device
    ///
    /// - parameters:
    ///     - username: particle username
    ///     - password: particle password
    ///     - device: particle device name
    /// - returns: nothing
    init(username: String, password: String, device: String) {
        self.username = username
        self.password = password
        self.device = device
        //!!! eventually OAuth will be supported, then switch over
    }
    
    /// Request to log off and release the authentication token
    ///
    /// - parameter void
    /// - returns: nothing
    func logoff() {
        if photon != nil {
            SparkCloud.sharedInstance().logout()
        }
    }
    
    /// Request a login. Will login if necessary then call the success or failure closure
    ///
    /// - parameters:
    ///     - success: function to call when login succeeds or already logged in
    ///     - failure: function to call when login fails
    /// - returns: integer representing the error or -1 if no error
    func login(success: (() -> Int)? = nil, failure: ((error: Int) -> Void)? = nil) -> Int {
        var returnVal = -1
        if photon == nil {
            SparkCloud.sharedInstance().loginWithUser(username, password: password) { (error:NSError!) -> Void in
                if (error != nil) {
                    print("Wrong credentials or no internet connectivity, please try again", terminator: "\n")
                    if let c = failure {
                        c(error: 0)
                    }
                }
                else {
                    print("Logged in", terminator: "\n")
                    SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]!, error:NSError!) -> Void in
                        if (error != nil) {
                            print("Check your internet connectivity", terminator: "\n")
                            if let c = failure {
                                c(error: 1)
                            }
                        }
                        else {
                            if let devices = sparkDevices as? [SparkDevice] {
                                for device in devices {
                                    if device.name == self.device {
                                        self.photon = device
                                        if let c = success {
                                            returnVal = c()
                                        }
                                    }
                                }
                            }
                            if self.photon == nil {
                                if let c = failure {
                                    c(error: 2)
                                }
                            }
                        }
                    }
                }
            }
        }
        else if let c = success
        {
            returnVal = c()
        }
        return returnVal
    }
    
    func close(closure: (() -> Void)? = nil) {
        function("###", closure: closure)
    }
    
    func open(closure: (() -> Void)? = nil) {
        function("####", closure: closure)
    }
    
    func closed(closure: ((val: Bool) -> Void)) {
        read("######", closure: closure)
    }
    
    func front(closure: ((val: Bool) -> Void)) {
        read("########", closure: closure)
    }
    
    func screen(closure: ((val: Bool) -> Void)) {
        read("#######", closure: closure)
    }
    
    /// Helper function to call a function
    ///
    /// - parameters:
    ///     - method: method name
    ///     - closure: function to call when success
    /// - returns: integer representing login errors
    func function(method: String, closure: (() -> Void)? = nil) {
        login({() -> Int in
            var returnVal = -1
            self.photon?.callFunction(method, withArguments: []) { (resultCode : NSNumber!, error : NSError!) -> Void in
                if (error == nil) {
                    print("\(method) succeeded", terminator: "\n")
                    if let c = closure {
                        c()
                    }
                    returnVal = 1
                }
                else {
                    print("\(method) failed", terminator: "\n")
                    returnVal = 0
                }
            }
            return returnVal
        })
    }
    
    /// Helper function to read a variable and pass the results (assuming boolean for now)
    ///
    /// - parameters:
    ///     - variable: variable name
    ///     - closure: function to call when success
    /// - returns: integer representing login errors
    func read(variable : String, closure: ((val: Bool) -> Void)? = nil) -> Int {
        return login({() -> Int in
            var returnVal = -1
            self.photon?.getVariable(variable, completion: { (result:AnyObject!, error:NSError!) -> Void in
                if (error != nil) {
                    print("Failed get status", terminator: "\n")
                }
                else {
                    if let r = result as? Int {
                        returnVal = r
                        if let c = closure {
                            c(val: r == 1);
                        }
                    }
                }
            })
            return returnVal
        })
    }
}