//
//  LoginViewController.swift
//  FireBaseChat
//
//  Created by Sanjeet Verma on 19/05/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
class LoginViewController: UIViewController,FBSDKLoginButtonDelegate,GIDSignInUIDelegate {

    var messageController:MessageController?
    var dictionary:[String:AnyObject]!
    let inputContainerView:UIView = {
    
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton:UIButton = {
    
        let button = UIButton(type:.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for:.touchUpInside)
        return button
    }()
    
    lazy var facebookloginButton:UIButton = {
    
        let button = FBSDKLoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = self
        button.readPermissions = ["email","public_profile","user_friends"]
        return button
    }()
    
    lazy var googleSigninButton: GIDSignInButton = {
    
        let googlebutton = GIDSignInButton()
        googlebutton.translatesAutoresizingMaskIntoConstraints = false
        return googlebutton
    }()
    
    let nameTextField:UITextField = {
    
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.layer.masksToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView:UIView = {
    
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailTextField:UITextField = {
    
        let tf = UITextField()
        tf.placeholder = "Email address"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let emailSeparatorView:UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField:UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    lazy var profileImageView:UIImageView = {
    
        let imageView = UIImageView()
        
        imageView.image = UIImage(named:"dilip")
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
        imageView.isUserInteractionEnabled = true
        
        
        
        return imageView
    }()
    
    let loginRegisterSegmentedControl:UISegmentedControl = {
    
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    func handleLoginRegisterChange(){
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change the height of inputcontainer view
        
        inputsViewcontainerHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //change the height of nametextfield
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(facebookloginButton)
        view.addSubview(googleSigninButton)
        
        setupinputContainerView()
        setuploginRegisterButton()
        setupProfileimageView()
        setuploginRegisterSegmentedControl()
        setupFacebookloginButton()
        setupGoogleSigninButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var inputsViewcontainerHeightAnchor:NSLayoutConstraint?
    var nameTextFieldHeightAnchor : NSLayoutConstraint?
    var emailTextFieldHeightAnchor : NSLayoutConstraint?
    var passwordTextFieldHeightAnchor : NSLayoutConstraint?
    
    func setupinputContainerView(){
        
        //need x,y,width,height
        
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsViewcontainerHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsViewcontainerHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)
        
        //need x,y,width,height
        
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x,y,width,height
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        //need x,y,width,height
        
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x,y,width,height
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x,y,width,height
        
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true

    }
    
    func setuploginRegisterButton(){
        
        //need x,y,width,height
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo:inputContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupFacebookloginButton(){
        
        //need x,y,width,height
        
        facebookloginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookloginButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 12).isActive = true
        facebookloginButton.widthAnchor.constraint(equalTo: loginRegisterButton.widthAnchor).isActive = true
        facebookloginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    
    func setupGoogleSigninButton(){
        
        googleSigninButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleSigninButton.topAnchor.constraint(equalTo: facebookloginButton.bottomAnchor, constant: 12).isActive = true
        googleSigninButton.widthAnchor.constraint(equalTo: facebookloginButton.widthAnchor).isActive = true
        googleSigninButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupProfileimageView(){
        
        //need x,y,width,height
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func handleLoginRegister(){
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
        
            handleLogin()
        }else{
        
            handleRegister()
        }
    }
    func handleLogin(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil{
            
                print("Error while login with user email - \(error)")
                return
            }else{
            
                self.messageController?.fetchUserAndSetupNavBarTitle()
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
    func setuploginRegisterSegmentedControl(){
        
        //need x,y,width,height
        
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor,multiplier:1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("Did logout from facebook")
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil{
        
            print("Error while login with facebook:\(error)")
            return
        }
        else
        {
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id,name,email,picture.type(large)"]).start(completionHandler: { (connection, result, err) in
                
                if err != nil
                {
                    print("Failded to start Graph request",err!)
                    return
                }else
                {
                    var imagedata = Data()
                    self.dictionary = result as! [String : AnyObject]
                    let name = self.dictionary["name"] as!String
                    let email = self.dictionary["email"] as! String
                    if let data1 = self.dictionary["picture"]
                    {
                        if let data = data1["data"] as? [String:AnyObject]
                        {
                            let url = data["url"] as! String
                            do
                            {
                                imagedata = try Data.init(contentsOf: URL(string: url)!)
                                
                            }catch let error as NSError{
                            
                                print("Error:\(error)")
                            }
                        }
                    }
                    
                    guard let accessToken = FBSDKAccessToken.current().tokenString else {
                        return
                    }
                    let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessToken)
                    
                    FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                        
                        if error != nil
                        {
                        
                            print("Failed login with Firebase:\(error?.localizedDescription)")
                            return
                        }
                        else
                        {
                            guard let uid = user?.uid else{
                                print("UId not available")
                                return
                            }
                            let imageName = UUID().uuidString
                            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
                                storageRef.put(imagedata, metadata: nil, completion: { (metaData, error) in
                                    
                                    if error != nil{
                                        
                                        print("Error while storage the image into firebase -\(error?.localizedDescription)")
                                        return
                                    }
                                    
                                    if let profileImageUrl = metaData?.downloadURL()?.absoluteString{
                                        
                                        let values = ["name":name,"email":email,"profileImageUrl":profileImageUrl]
                                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                                    }
                                })
                            }
                        })
                    }
                })
            }
        }

}

extension UIColor{

    convenience init(r:CGFloat,g:CGFloat,b:CGFloat) {
        
        self.init(red:r/255,green:g/255,blue:b/255,alpha:1)
    }
}
