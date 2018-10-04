//
//  LoginController.swift
//  Messenger
//
//  Created by liroy yarimi on 04/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    //MARK: - Properties initialization
    
    let inputContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 80, green: 101, blue: 161)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    let nameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl : UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1 //select the Register button
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    //MARK: - Main - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.rgb(red: 61, green: 91, blue: 151)
        
        
        
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
        
    }
    
    //MARK: - handle functions
    
    @objc func handleLoginRegisterChange(){
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of inputContainerView
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //change height of emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true

    }
    
    @objc func handleLoginRegister(){
        loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? handleLogin() : handleRegister()
    }
    
    func handleLogin(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text else{
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!)
                return
            }
            
            //successfully log in our user
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        
        //create a new user on our firebase with email and password
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!)
                return
            }
            
            guard let uid = user?.user.uid else {return}
            
            //successfullt authenticated user
            let ref = Database.database().reference(fromURL: "https://messenger-55009.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            
            let values = ["name": name, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil{
                    print(err!)
                    return
                }
                print("save user successfully into Firebase database")
                
                self.dismiss(animated: true, completion: nil)
            })
            
            
        }
    }
    
    //MARK: - Functions
    
    func setupLoginRegisterSegmentedControl(){
        
        let constraints = [
            loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12),
            loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupProfileImageView(){
        let constraints = [
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12),
            profileImageView.widthAnchor.constraint(equalToConstant: 200),
            profileImageView.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView(){
        
        inputContainerView.addSubview(nameTextField)//addSubview need to be before the constraint
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)
        
        
        inputsContainerViewHeightAnchor =  inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        nameTextFieldHeightAnchor =             nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true

        emailTextFieldHeightAnchor =             emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor =             passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true

        
        let constraints = [
            inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inputContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -24),
            
            nameTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            
            nameSeparatorView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            nameSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            emailTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            
            emailSeparatorView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            emailSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            passwordTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

    }
    
    func setupLoginRegisterButton(){
        
        let constraints = [
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12),
            loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    
    //make the status bar a white color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
