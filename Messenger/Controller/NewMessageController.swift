//
//  NewMessageController.swift
//  Messenger
//
//  Created by liroy yarimi on 06/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController , UISearchBarDelegate{
    
    let cellId = "cellId"
    var users = [User]()
    
    var usersToPresent = [User]()
    
//    //add a search bar
//    let searchBar:UISearchBar = {
//        let search = UISearchBar()
//        search.searchBarStyle = UISearchBar.Style.prominent
//        search.placeholder = " Search..."
//        search.sizeToFit()
//        search.isTranslucent = false
//        search.backgroundImage = UIImage()
//
//        return search
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        searchBar.delegate = self
//        view.addSubview(searchBar)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
        
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
//            print(snapshot)
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                
                if let name = dictionary["name"] as? String, let email = dictionary["email"] as? String, let image = dictionary["profileImageUrl"] as? String{
                    let user = User(name: name, email: email, profileImageUrl: image)
                    user.id = snapshot.key
//                    print(user.name ,user.email)
                    self.users.append(user)
                    
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl)
        
        return cell
    }
    
    //height for every row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
//            print("dismiss")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
        }
    }

}
