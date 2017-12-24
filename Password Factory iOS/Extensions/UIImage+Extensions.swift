//
//  UIImage+Extensions.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/23/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import Foundation
extension UIImage {
    
    func combine(_ withImage: UIImage) -> UIImage {
        let firstImage = self
        let secondImage = withImage
        let newImageWidth  = firstImage.size.width + secondImage.size.width
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        let firstImageDrawX  : CGFloat = 0.0
        let firstImageDrawY  : CGFloat = 0.0
        
        let secondImageDrawX = firstImage.size.width
        let secondImageDrawY : CGFloat = 0.0
        
        firstImage .draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}
