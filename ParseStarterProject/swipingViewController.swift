//
//  swipingViewController.swift
//  ParseStarterProject
//
//  Created by Iram Khan on 12/06/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class swipingViewController: UIViewController {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    
    var displayedUserId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(swipingViewController.wasDragged(_:)))
        userImage.addGestureRecognizer(gesture)
        userImage.userInteractionEnabled = true
        
        // Location
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) in
            if error != nil {
                print(error)
            } else {
                
                if let geoPoint = geoPoint {
                    
                    PFUser.currentUser()?["location"] = geoPoint
                    PFUser.currentUser()?.saveInBackground()
                }
                
            }
        }
        
        updateImage()
    }
    
    func updateImage() {
        var query = PFUser.query()
        
        if let latitude = PFUser.currentUser()?["location"].latitude {
            if let longitude = PFUser.currentUser()?["location"].longitude {
                query?.whereKey("location", withinGeoBoxFromSouthwest:  PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
            }
        }
        
        
        var interestedIn = "male"
        
        if PFUser.currentUser()?["interestedInWomen"] as! Bool == true {
            interestedIn = "female"
        }
        
        var isFemale = true
        
        if PFUser.currentUser()?["gender"] as! String == "male" {
            isFemale = false
        }
        
        query?.whereKey("gender", equalTo: interestedIn)
        query?.whereKey("interestedInWomen", equalTo: isFemale)
        
        var ignoredUsers = [""]
        
        if let  acceptedUsers = PFUser.currentUser()?["accepted"] {
            
            ignoredUsers += acceptedUsers as! Array
        }
        
        if let  rejectedUsers = PFUser.currentUser()?["rejected"] {
            ignoredUsers += rejectedUsers as! Array
        }
        
        query?.whereKey("objectId", notContainedIn: ignoredUsers)
        
        query?.limit = 1
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error != nil {
                print(error)
            } else if let objects = objects! as? [PFObject] {
                for object in objects {
                    
                    
                    self.displayedUserId = object.objectId!
                    
                    let imageFile = object["image"] as! PFFile
                    
                    imageFile.getDataInBackgroundWithBlock({ (data, error) in
                        if error != nil {
                            print(error)
                        } else {
                            if let data = data {
                                self.userImage.image = UIImage(data: data)
                            }
                        }
                    })
                }
            }
        })

    }
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        let label = gesture.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        let scale = min(50 / abs(xFromCenter), 1)
        
        // Rotation and stretch
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200) // 1 = 60 degrees, 6 = 360 degrees
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var acceptedOrRejected = ""
            
            if label.center.x < 100 {
                acceptedOrRejected = "rejected"
            }
            
            if label.center.x > self.view.bounds.width - 100 {
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" {
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: acceptedOrRejected)
                PFUser.currentUser()?.saveInBackground()
            }
            
            
            rotation = CGAffineTransformMakeRotation(0) // 1 = 60 degrees, 6 = 360 degrees
            stretch = CGAffineTransformScale(rotation, 1.0, 1.0)
            label.transform = stretch
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
            updateImage()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logOut" {
            PFUser.logOut()
            
        }
    }
    
    

}
