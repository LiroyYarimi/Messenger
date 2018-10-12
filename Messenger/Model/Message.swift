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
    
    init(fromId: String?, text: String?, timestamp: String?, toId: String?){
        self.fromId = fromId
        self.text = text
        self.timestamp = timestamp
        self.toId = toId
    }
    
    func chatPartnerId() -> String?{
        
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
        
//        if fromId == Auth.auth().currentUser?.uid{
//            return toId
//        }else{
//            return fromId
//        }
    }

}
