//
//  SIgnUpViewController.swift
//  ParseStarterProject
//
//  Created by Iram Khan on 12/06/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SIgnUpViewController: UIViewController {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var interestedInWomen: UISwitch!
    @IBAction func signUpButton(sender: AnyObject) {
        
        PFUser.currentUser()!["interestedInWomen"] = interestedInWomen.on
        PFUser.currentUser()?.saveInBackground()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender"])
        graphRequest.startWithCompletionHandler { (connection, result, error) in
            if error != nil {
                print(error)
            } else
            if let result = result {
                
                PFUser.currentUser()!["gender"] = result["gender"]!
                PFUser.currentUser()!["name"] = result["name"]!
                
                PFUser.currentUser()?.saveInBackground()
                
                let userId = result["id"]! as! String
                
                let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                
                if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
                    if let data = NSData(contentsOfURL: fbpicUrl) {
                        self.userImage.image = UIImage(data: data)
                        
                        let imageFile:PFFile = PFFile(data: data)!
                        
                        PFUser.currentUser()?["image"] = imageFile
                        PFUser.currentUser()?.saveInBackground()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
