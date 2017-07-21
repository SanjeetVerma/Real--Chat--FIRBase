//
//  AppDelegate.swift
//  FireBaseChat
//
//  Created by Sanjeet Verma on 19/05/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      
        
        FIRApp.configure()
        FBSDKApplicationDelegate .sharedInstance() .application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        window = UIWindow(frame:UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: MessageController())
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
      
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate .sharedInstance() .application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error{
        
            print("Failed to log into Google:\(error.localizedDescription)")
            return
        }else{
                guard let authentication = user.authentication else {
                    return
              }
            
             let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            FIRAuth.auth()?.signIn(with: credential, completion: { (User, error) in
                
                if error != nil{
                
                    print("Failed to create a firebase User with Google account:\(error?.localizedDescription)")
                    return
                }else{
                
                    guard let uid = User?.uid else{
                        print("UId not available")
                        return
                    }
                    var imagedata = Data()
                    let email = user.profile.email
                    let name = user.profile.name
                    let ImageUrl = user.profile.imageURL(withDimension: 500)
                    do{
                        imagedata = try Data.init(contentsOf:ImageUrl!)
                        
                    }catch let error as NSError{
                        
                        print("Error:\(error)")
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
                            let instace = LoginViewController()
                            instace.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        }
                    })
                }
            })
        }
    }

}

