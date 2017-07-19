//
//  LoginController+handlers.swift
//  FireBaseChat
//
//  Created by Sanjeet Verma on 22/05/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController :UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    func handleRegister(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text,let name = nameTextField.text else {
            
            print("Form is not valid")
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil{
                
                print("Error while Registering the user - \(error?.localizedDescription)")
                
                return
            }else{
                
                guard let uid = user?.uid else{
                    print("UId not available")
                    return
                }
                
                let imageName = UUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
                
                if let profileImage = self.profileImageView.image,let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                    storageRef.put(uploadData, metadata: nil, completion: { (metaData, error) in
                        
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
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid:String,values:[String:AnyObject]){
    
        //let ref = FIRDatabase.database().reference(fromURL: "https://fir-chat-bcd30.firebaseio.com/")
         let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil{
                
                print("Error while saving the registerd data -\(err?.localizedDescription)")
                return
            }else{
                
                //self.messageController?.fetchUserAndSetupNavBarTitle()
                //self.messageController?.navigationItem.title  = values["name"] as? String
                
                let user = User()
                user.setValuesForKeys(values)
                self.messageController?.setupNavBarWithUser(user: user)
                self.dismiss(animated: true, completion: nil)
                print("Saved user succesfully into Firebase db")
            }
        })
        
    }
    
    func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
        
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
        
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
        
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print("Cancel button tapped")
        
        dismiss(animated: true, completion: nil)
    }
    
}
