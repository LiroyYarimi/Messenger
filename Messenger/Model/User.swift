//
//  User.swift
//  Messenger
//
//  Created by liroy yarimi on 06/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit

class User {
    
    var name: String
    var email: String
    var profileImageUrl:String?
    var id : String?
    
    init( name: String, email:String, profileImageUrl:String?){
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
}
