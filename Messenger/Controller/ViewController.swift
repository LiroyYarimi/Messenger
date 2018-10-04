//
//  ViewController.swift
//  Messenger
//
//  Created by liroy yarimi on 04/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //user is not log in
        if Auth.auth().currentUser?.uid == nil{
//            handleLogout()
            //go to handleLogout() with a little delay (for avoid the warning message)
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
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

