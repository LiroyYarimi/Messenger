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
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let newMessageImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    //height for every row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return}
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
            guard let dictionary = snapshot.value as? [String:AnyObject] else{return}
            let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String)
            user.id = chatPartnerId
            self.showChatControllerForUser(user: user)
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        cell.message = message

        return cell
    }
    
    func observeUserMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return} //user-message id
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
//            print(snapshot)
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
//                print(snapshot)
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
            
            
//
            
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageId: String){
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                //--
                let message = Message(dictionary: dictionary)
                if let chatPartnerId = message.chatPartnerId(){
                    self.messagesDictionary[chatPartnerId] = message
                    
                }
                
                self.attemptReloadOfTable()
                //--
//                if let fromId = dictionary["fromId"] as? String, let toId = dictionary["toId"] as? String, let timestamp = dictionary["timestamp"] as? String{
//
//                    let imageUrl = dictionary["imageUrl"] as? String
//                    let text = dictionary["text"] as? String
//                    let imageWidth = dictionary["imageWidth"] as? Int
//                    let imageHeight = dictionary["imageHeight"] as? Int
//
//                    let message = Message(fromId: fromId, text: text, timestamp: timestamp, toId: toId, imageUrl: imageUrl, imageHeight: imageHeight, imageWidth: imageWidth)
//
//                    if let chatPartnerId = message.chatPartnerId(){
//                        self.messagesDictionary[chatPartnerId] = message
//
//                    }
//
//                    self.attemptReloadOfTable()
//
//                }
                
            }
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable(){
        
        //we want to add the messages only when we need to reload the table view
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            if let message1Timestamp = message1.timestamp, let message2Timestamp = message2.timestamp{
                let t1 = (message1Timestamp as NSString).doubleValue
                let t2 = (message2Timestamp as NSString).doubleValue
                return t1 > t2
            }
            return false
        })
        
        self.timer?.invalidate()//cancel the timer
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)//after 0.1 second, call the function handleReloadTable()
        //but because we keep cancel the timer, we call the function only one time, at the end of the last message that we reload
    }
    
    //when the timer end it call this function
    @objc func handleReloadTable(){
        self.tableView.reloadData()//now this is call only one time!
//        print("reload table")
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
                
                let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String)
                self.setupNavBarWithUser(user: user)
                
//                self.navigationItem.title = dictionary["name"] as? String
            }
            
            
        }, withCancel: nil)
    }
    
    
    //present profile image and user name
    func setupNavBarWithUser(user: User){

        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
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

        profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl)

        let constraints = [
            profileImageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            //this two constraints is the reason why the addGestureRecognizer doesn't work before (it was before equalToConstant: 40 )
//            profileImageView.widthAnchor.constraint(equalTo: titleView.heightAnchor),
//            profileImageView.heightAnchor.constraint(equalTo: titleView.heightAnchor)
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
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






