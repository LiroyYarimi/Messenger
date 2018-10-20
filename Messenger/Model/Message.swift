//
//  Message.swift
//  Messenger
//
//  Created by liroy yarimi on 11/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase

class Message {
    
    var fromId: String?
    var text: String?
    var timestamp: String?
    var toId: String?
    
    var imageUrl: String?
    var imageHeight: Int?
    var imageWidth: Int?
    
//    init(fromId: String?, text: String?, timestamp: String?, toId: String?, imageUrl: String?, imageHeight: Int?, imageWidth: Int?){
//        self.fromId = fromId
//        self.text = text
//        self.timestamp = timestamp
//        self.toId = toId
//        self.imageUrl = imageUrl
//        self.imageWidth = imageWidth
//        self.imageHeight = imageHeight
//    }
    
    init(dictionary: [String:AnyObject]) {
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        timestamp = dictionary["timestamp"] as? String
        text = dictionary["text"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? Int
        imageHeight = dictionary["imageHeight"] as? Int
        
    }
    
    func chatPartnerId() -> String?{
//        print(Auth.auth().currentUser?.uid)
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }

}
