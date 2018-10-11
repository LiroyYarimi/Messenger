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
    
    let cellId = "cellId"
    
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let newMessageImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        observeMessages()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    //height for every row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        cell.message = message

        return cell
    }
    
    func observeMessages(){
        
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
                if let fromId = dictionary["fromId"] as? String, let toId = dictionary["toId"] as? String, let timestamp = dictionary["timestamp"] as? String, let text = dictionary["text"] as? String{
                    
                    let message = Message(fromId: fromId, text: text, timestamp: timestamp, toId: toId)
//                    self.messages.append(message)
                    if let toId = message.toId{
                        self.messagesDictionary[toId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            
                            if let message1Timestamp = message1.timestamp, let message2Timestamp = message2.timestamp{
                                let t1 = (message1Timestamp as NSString).doubleValue
                                let t2 = (message2Timestamp as NSString).doubleValue
                                return t1 > t2
                            }
                            return false
                        })
                    }
                    
                    self.tableView.reloadData()
                    }
                
            }
            
//            print(snapshot)
            
        }, withCancel: nil)
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
    
    
    //present profile image and user name
    func setupNavBarWithUser(user: User){

//        self.navigationItem.title = user.name

        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)

//        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(showChatController))
//        zoomTap.numberOfTapsRequired = 1
//        titleView.addGestureRecognizer(zoomTap)
//        titleView.isUserInteractionEnabled = true

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        titleView.addSubview(profileImageView)//containerView

        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        let constraints = [
            profileImageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            //this two constraints is the reason why the addGestureRecognizer doesn't work before (it was before equalToConstant: 40 )
            profileImageView.widthAnchor.constraint(equalTo: titleView.heightAnchor),
            profileImageView.heightAnchor.constraint(equalTo: titleView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
//
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

    func showChatControllerForUser(user: User){

        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
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






