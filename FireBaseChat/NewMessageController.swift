//
//  NewMessageController.swift
//  FireBaseChat
//
//  Created by Sanjeet Verma on 20/05/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import Firebase
class NewMessageController: UITableViewController {

    let cellid = "CellId"
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellid)
        fetchUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    func handleCancel(){
        
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser(){
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
            
                let user = User()
                user.id = snapshot.key
                // if you use this setter,your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                DispatchQueue.main.async {
                   self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! UserCell
        let cell = UserCell(style: .subtitle, reuseIdentifier: cellid)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl{
        
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    var messageController : MessageController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true){
        
            let user = self.users[indexPath.row]
            self.messageController?.showChatControllerForUser(user: user)
        }
    }
}











