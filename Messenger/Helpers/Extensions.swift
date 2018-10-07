//
//  Extensions.swift
//  Messenger
//
//  Created by liroy yarimi on 04/10/2018.
//  Copyright © 2018 Liroy Yarimi. All rights reserved.
//

import UIKit

//MARK: - Extension - easyer to change color
/***************************************************************/

extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}



//load image from firebase
//save all images in our cache
let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView{
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        //because the cell is reload from different cell so let's make nil first and then load the right image
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        
        //image isn't in cache so let's download it
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {//dispatch_async(dispatch_get_main_queue(), {

                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
            
            }.resume()
    }
    
}
