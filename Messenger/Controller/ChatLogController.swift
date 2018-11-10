//
//  ChatLogController.swift
//  Messenger
//
//  Created by liroy yarimi on 10/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase
//import MobileCoreServices
//import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate , UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{//notes is UIViewController (and not UITableViewController)
    
    let cellId = "cellId"
    var messages = [Message]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    let bubbleWidthForImageMessage : CGFloat = 250
    
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
        
//        setupKeyboardObservers()//doesnt work..
    }
    
    //MARK:- create a input container view that will place always(!) on top of the keyboard
    
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
        containerView.backgroundColor = .white
        
        //create image button
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        let uploadImageViewConstraints = [
            uploadImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            uploadImageView.widthAnchor.constraint(equalToConstant: 44),
            uploadImageView.heightAnchor.constraint(equalToConstant: 44)
        ]
        NSLayoutConstraint.activate(uploadImageViewConstraints)
        
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
            inputTextField.leadingAnchor.constraint(equalTo: uploadImageView.trailingAnchor, constant: 8),
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
        
        cell.chatLogController = self
        
//        cell.backgroundColor = .blue
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        //change bubble view width to the text width size
        if let text = message.text{
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil{
            //fall in here if it's image message
            cell.bubbleWidthAnchor?.constant = bubbleWidthForImageMessage
            cell.textView.isHidden = true
        }
        
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        }else{
            cell.messageImageView.isHidden = true
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
    
    //this function call every time the size of the view change (lancscape rotate)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        
//        print(UIScreen.main.bounds.width)
//        print(UIScreen.main.bounds.height)
//        let height = self.startingFrame!.height / self.startingFrame!.width * UIScreen.main.bounds.width
//        let width = self.startingFrame!.width / self.startingFrame!.height * UIScreen.main.bounds.height
//        self.inputContainerView.alpha = 0
//        if let keyWindow = UIApplication.shared.keyWindow{
//            if height > UIScreen.main.bounds.height{
//                //Landscape
////                self.zoomingImageView?.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor).isActive = true
////                self.zoomingImageView?.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor).isActive = true
//                self.zoomingImageView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
//                self.zoomingImageView?.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
//                
//            }else{
//                //portrait
//                
//                self.zoomingImageView?.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor).isActive = true
//                self.zoomingImageView?.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor).isActive = true
//                self.zoomingImageView?.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor).isActive = true
//                self.zoomingImageView?.heightAnchor.constraint(equalToConstant: height).isActive = true
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        
        let message = messages[indexPath.row]
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 20
        }else if let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
            
            height = CGFloat(imageHeight) / CGFloat(imageWidth) * bubbleWidthForImageMessage
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
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {return}
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
//            print(snapshot)
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot)
                guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
                //--
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                self.collectionView.reloadData()
                //scroll to the last index
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    
    
    //this func call when user press on "Enter" button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        return true
    }
    
    
    
    
    //MARK:- second way to fix the keyboard
    
    func setupKeyboardObservers(){
        if messages.count > 0{
            NotificationCenter.default.addObserver(self, selector: #selector(handleKayboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func handleKayboardDidShow(){
        
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
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
    
    @objc func handleSendButton(){
        
        if self.inputTextField.text == ""{
            return
        }
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let values = ["text" : inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": "\(timestamp)"]
        sendMessageWithProperties(values: values)
    }
    
    private func sendMessageWithProperties(values: [String:Any]){
        
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()//create list of messages
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        
        childRef.updateChildValues(values){ (error, ref) in
            if error != nil{
                print(error!)
                return
            }
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    
    //MARK:- handle image picker
    
    //image picker
    @objc func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
//        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String] //for upload video
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL]{
//            print("here the file url ", videoUrl)
//            return
//        }
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){
        
        let imageName = NSUUID().uuidString// unique string
        let storageRef = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil{
                    print("Failed to upload image:", error!)
                    return
                }
                storageRef.downloadURL(completion: { (url, err) in
                    if err != nil{
                        print(err!)
                        return
                    }
                    
                    if let imageUrl = url?.absoluteString{
                        self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                    }
                })
            }
        }
        
        
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let values = ["toId": toId, "fromId": fromId, "timestamp": "\(timestamp)","imageUrl" : imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : Any]
        sendMessageWithProperties(values: values)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- handle zoom in for image view
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
//    var startingImageView: UIImageView?
    var zoomingImageView:UIImageView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView){
//        print("performZoomInForStartingImageView")
        
//        self.startingImageView = startingImageView
//        self.startingImageView?.isHidden = true

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        if startingFrame == nil {return}
//        print(startingFrame)
        
        zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView?.backgroundColor = .red
        zoomingImageView?.image = startingImageView.image
        zoomingImageView?.isUserInteractionEnabled = true
        zoomingImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            
//            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView = UIView()
            keyWindow.addSubview(blackBackgroundView!)
            
            blackBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
            blackBackgroundView?.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor).isActive = true
            blackBackgroundView?.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
            blackBackgroundView?.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor).isActive = true
            blackBackgroundView?.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
            
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0 //it start hidden
//            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView!)
            zoomingImageView?.translatesAutoresizingMaskIntoConstraints = false
//            zoomingImageView.alpha = 0
            

            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
                self.blackBackgroundView?.alpha = 1

                self.inputContainerView.alpha = 0//hide the inputContainerView
//                print(keyWindow.frame)
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                let width = self.startingFrame!.width / self.startingFrame!.height * keyWindow.frame.height
                if height > keyWindow.frame.height{
//                    print(keyWindow.frame)
                    self.zoomingImageView?.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
                    self.zoomingImageView?.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
                    self.zoomingImageView?.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor).isActive = true
                    self.zoomingImageView?.widthAnchor.constraint(equalToConstant: width).isActive = true
                }else{
//                    print(keyWindow.frame)

                    self.zoomingImageView?.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor).isActive = true
                    self.zoomingImageView?.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor).isActive = true
                    self.zoomingImageView?.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor).isActive = true
                    self.zoomingImageView?.heightAnchor.constraint(equalToConstant: height).isActive = true
                }


//                zoomingImageView.alpha = 1

//                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
//
//                zoomingImageView.center = keyWindow.center

            }) { (completed) in
//                do nothing
            }
            
        }
        
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){

        if let zoomOutImageView = tapGesture.view{
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
//                self.startingImageView?.isHidden = false
            }
            
        }
        
        
    }
    
}


