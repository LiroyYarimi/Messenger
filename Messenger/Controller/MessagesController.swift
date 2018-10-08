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
        
        if Auth.auth().currentUser?.uid != nil{
            fetchUserAndSetupNavBarTitle()

            
        }else{//user is not log in
            //go to handleLogout() with a little delay (for avoid the warning message)
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            //                print(snapshot)
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as? String)
                self.setupNavBarWithUser(user: user)
                
//                self.navigationItem.title = dictionary["name"] as? String
            }
            
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User){
        
//        self.navigationItem.title = user.name
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = .red
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        titleView.addSubview(profileImageView)

        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        let constraints = [
            profileImageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameLabel)
        
        let constraintsName = [
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraintsName)
        
        self.navigationItem.titleView = titleView
        
        
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
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    

}

