//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit

class ViewController: UIViewController {

    @IBAction func signIn(sender: AnyObject) {
        let permissions = ["public_profile", "email"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user, error) in
            if let error = error {
                print(error)
            } else {
                if let user = user {
                    
                    print(user)
                    if let interestedInWomen = user["interestedInWomen"] {
                        self.performSegueWithIdentifier("logUserIn", sender: self)
                        
                    } else {
                        self.performSegueWithIdentifier("showSignInScreen", sender: self)
                    }
                    
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let username = PFUser.currentUser()?.username {
            if let interestedInWomen = PFUser.currentUser()!["interestedInWomen"] {
                self.performSegueWithIdentifier("logUserIn", sender: self)
                
            } else {
                self.performSegueWithIdentifier("showSignInScreen", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

