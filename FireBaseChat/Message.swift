//
//  Message.swift
//  FireBaseChat
//
//  Created by Sanjeet Verma on 22/05/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {

    var fromId:String?
    var text:String?
    var timestamp:NSNumber?
    var toId:String?
    
    var imageUrl :String?
    var imageHeight : NSNumber?
    var imageWidth : NSNumber?
    
    var videoUrl : String?
    
    func chatPartnerId() -> String? {
        
     
        if fromId == FIRAuth.auth()?.currentUser?.uid{
            
            return toId
        }else{
            
            return fromId
        }
    }
    
    init(dictionary:[String:AnyObject]){
    
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
        
        
    }
}
