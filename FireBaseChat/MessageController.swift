//
//  ViewController.swift
//  FireBaseChat
//
//  Created by Sanjeet Verma on 19/05/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
class MessageController: UITableViewController {
    
    var cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action:#selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfuserIsloggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        //observerMessage()
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func observerUserMessage(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageId:String){
    
        let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                let message = Message(dictionary:dictionary)
                //message.setValuesForKeys(dictionary)
                //self.messages.append(message)
                
                if let chatPartnerId = message.chatPartnerId(){
                    
                    self.messagesDictionary[chatPartnerId] = message
                    
                }
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable(){
    
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    var timer:Timer?
    
    func handleReloadTable(){
        
        self.messages = Array(self.messagesDictionary.values)
        
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! < (message2.timestamp?.intValue)!
        })
        
        //Reload the table
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
    }
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    func observerMessage(){
        
        let ref = FIRDatabase.database().reference().child("messages")
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                let message = Message(dictionary:dictionary)
                //message.setValuesForKeys(dictionary)
                //self.messages.append(message)
                
                if let toId = message.toId{
                    
                    self.messagesDictionary[toId] = message
                    
                    self.messages = Array(self.messagesDictionary.values)
                    
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        
                        return (message1.timestamp?.intValue)! < (message2.timestamp?.intValue)!
                    })
                }
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId(){
        
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil{
                
                    print("Failed to delete messages:\(error?.localizedDescription)")
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                //self.messages.remove(at: indexPath.row)
                //self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UserCell(style: .subtitle, reuseIdentifier: cellId)
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else{
                
                return
            }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
        }, withCancel: nil)
    }
    
    func checkIfuserIsloggedIn(){
        
        //user is not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictinoary = snapshot.value as? [String:AnyObject]{
                
                //self.navigationItem.title = dictinoary["name"] as? String
                
                let user = User()
                user.setValuesForKeys(dictinoary)
                self.setupNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user:User){
        
        //self.navigationItem.title = user.name
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observerUserMessage()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl{
            
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        // need x,y,width,height
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLable = UILabel()
        containerView.addSubview(nameLable)
        nameLable.text = user.name
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        
        // need x,y,width,height
        
        nameLable.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLable.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLable.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLable.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        // need x,y,width,height
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
        
    }
    
    func showChatControllerForUser(user:User){
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    func handleLogout(){
        
        do{
            try FIRAuth.auth()?.signOut()
             FBSDKLoginManager().logOut()
            
        }catch let logouterror{
            
            print(logouterror)
        }
        let loginController = LoginViewController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func handleNewMessage(){
        
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navController  = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
}

