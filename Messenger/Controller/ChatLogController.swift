//
//  ChatLogController.swift
//  Messenger
//
//  Created by liroy yarimi on 10/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate , UICollectionViewDelegateFlowLayout{//notes is UIViewController (and not UITableViewController)
    
    let cellId = "cellId"
    var messages = [Message]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self //this is for send message with enter on the keyboard
        return textField
    }()
    
    //MARK:- Main - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)//make a 8 pixel space between the bubble and the top view
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)//change the scroll size
        collectionView.alwaysBounceVertical = true //make it dragable
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive //dismiss the keyboard by scroll
        
//        setupInputComponents()
//
//        setupKeyboardObservers()
    }
    
    //MARK:- create a input container view that will place always(!) on top of the keyboard
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
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
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    

    //MARK:- table view function
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
//        cell.backgroundColor = .blue
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        //change bubble view width to the text width size
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outcoming blue bubble
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleTrailingAnchor?.isActive = true
            cell.bubbleLeadingAnchor?.isActive = false
        }else{
            //incoming gray bubble
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleTrailingAnchor?.isActive = false
            cell.bubbleLeadingAnchor?.isActive = true
        }
    }
    
    //this function call every time the size of the view change (lancscape)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        if let text = messages[indexPath.row].text{
            height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    //colculate the height size for each bubble
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    func observeMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
//            print(snapshot)
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot)
                guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
                let message = Message(fromId: dictionary["fromId"] as? String, text: dictionary["text"] as? String, timestamp: dictionary["timestamp"] as? String, toId: dictionary["toId"] as? String)
                if message.chatPartnerId() == self.user?.id{
                    self.messages.append(message)
                    self.collectionView.reloadData()
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    @objc func handleSendButton(){
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()//create list of messages
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let values = ["text" : inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": "\(timestamp)"]
        //        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values){ (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
        
    }
    
    //this func call when user press on "Enter" button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
    
//    func setupInputComponents(){
//
//        let containerView = UIView()
//        containerView.backgroundColor = .white
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(containerView)
//
//        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)//safeAreaLayoutGuide
//        containerViewBottomAnchor?.isActive = true
//
//        let containerViewConstraints = [
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
//            containerView.heightAnchor.constraint(equalToConstant: 50)
//        ]
//        NSLayoutConstraint.activate(containerViewConstraints)
//
////        //create sent button
////        let sendButton = UIButton(type: .system)
////        sendButton.setTitle("Send", for: .normal)
////        sendButton.translatesAutoresizingMaskIntoConstraints = false
////        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
////        containerView.addSubview(sendButton)
////
////        let sendButtonConstraints = [
////            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
////            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
////            sendButton.widthAnchor.constraint(equalToConstant: 80),
////            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
////        ]
////        NSLayoutConstraint.activate(sendButtonConstraints)
////
////        //create text field is outside (on the top)
////        containerView.addSubview(inputTextField)
////
////        let inputTextFieldConstarints = [
////            inputTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
////            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
////            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor),
////            inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor)
////        ]
////        NSLayoutConstraint.activate(inputTextFieldConstarints)
////
////        //create separator line
////        let separatorLineView = UIView()
////        separatorLineView.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
////        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
////        containerView.addSubview(separatorLineView)
////
////        let separatorLineViewConstarints = [
////            separatorLineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
////            separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor),
////            separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
////            separatorLineView.heightAnchor.constraint(equalToConstant: 1)
////        ]
////        NSLayoutConstraint.activate(separatorLineViewConstarints)
//    }
    
    
    
    
    //MARK:- second way to fix the keyboard
    
    func setupKeyboardObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //remove observer (on the keyboard)
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification){
        containerViewBottomAnchor?.constant = 0
        
        if let userInfo = notification.userInfo {
            let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    
    @objc func handleKeyboardWillShow(notification: NSNotification){
        
        
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
                //                print("show keyboard")
                //                print(keyboardSize.height)
                containerViewBottomAnchor?.constant = -keyboardSize.height
                
                let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                UIView.animate(withDuration: keyboardDuration) {
                    self.view.layoutIfNeeded()
                }
                
            }
        }
    }
}


