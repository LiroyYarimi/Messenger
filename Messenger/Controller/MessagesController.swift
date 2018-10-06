//
//  ViewController.swift
//  Messenger
//
//  Created by liroy yarimi on 04/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let newMessageImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){
        
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
//                print(snapshot)
                if let dictionary = snapshot.value as? [String:AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
                
            }, withCancel: nil)
            
        }else{//user is not log in
            //go to handleLogout() with a little delay (for avoid the warning message)
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        //to get a navigation bar in our new controller (NewMessageController)
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }

    @objc func handleLogout(){
        
        //the user is logout, so send him to loginViewController to login
        do{
            try Auth.auth().signOut()
        }catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    

}

