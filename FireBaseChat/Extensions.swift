//
//  Extensions.swift
//  FireBaseChat
//
//  Created by Sanjeet Verma on 22/05/17.
//  Copyright © 2017 Sanjeet Verma. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView{

    func loadImageUsingCacheWithUrlString(urlString:String){
        
        
        self.image = nil
        //Check cache image first
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
        
            self.image = cachedImage as? UIImage
            return
        }
        // Other wise fire off a new download
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil{
                
                print("Error while getting the image from firebase -\(error?.localizedDescription)")
            }else{
                
                DispatchQueue.main.async {
                
                    if let downloadedImage = UIImage(data:data!){
                    
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                    }
                }
            }
        }).resume()
    }
}
