//
//  ChatLogController.swift
//  Messenger
//
//  Created by liroy yarimi on 10/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {//notes is UIViewController (and not UITableViewController)
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
        }
    }
    
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self //this is for send message with enter on the keyboard
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.title = "Chat Log Controller"
        
        collectionView.backgroundColor = .white
        
        setupInputComponents()
    }
    
    func setupInputComponents(){
        
        let containerView = UIView()
//        containerView.backgroundColor = .red
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        let containerViewConstraints = [
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(containerViewConstraints)
        
        //create sent button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        let sendButtonConstraints = [
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ]
        NSLayoutConstraint.activate(sendButtonConstraints)
        
        //create text field is outside (on the top)
        containerView.addSubview(inputTextField)
        
        let inputTextFieldConstarints = [
            inputTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ]
        NSLayoutConstraint.activate(inputTextFieldConstarints)
        
        //create separator line
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        let separatorLineViewConstarints = [
            separatorLineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor),
            separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(separatorLineViewConstarints)
    }
    
    @objc func handleSendButton(){
//        print(inputTextField.text!)
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()//create list of messages
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let value = ["text" : inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": "\(timestamp)"]
        childRef.updateChildValues(value)
        
        
        
    }
    
    //this func call when user press on "Enter" button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
}
