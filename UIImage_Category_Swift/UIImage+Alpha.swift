//
//  UIImage+Alpha.swift
//
//  Created by Rupesh Kumar on 10/23/15.
//  Copyright © 2015 Rupesh Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    // Returns true if the image has an alpha layer
    func hasAlpha() -> Bool
    {
        let alpha: CGImageAlphaInfo = CGImageGetAlphaInfo(self.CGImage)
        return (alpha == CGImageAlphaInfo.First || alpha == CGImageAlphaInfo.Last || alpha == CGImageAlphaInfo.PremultipliedFirst || alpha == CGImageAlphaInfo.PremultipliedLast)
    }
    
    
    // Returns a copy of the given image, adding an alpha channel if it doesn't already have one
    func imageWithAlpha() -> UIImage
    {
        if self.hasAlpha()
        {
            return self
        }
        
        let imageRef: CGImageRef = self.CGImage!
        let width: Int = CGImageGetWidth(imageRef)
        let height: Int = CGImageGetHeight(imageRef)
        
        // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
        let offscreenContext: CGContextRef = CGBitmapContextCreate(nil, width, height, 8, 0, CGImageGetColorSpace(imageRef), CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue)!
        
        // Draw the image into the context and retrieve the new image, which will now have an alpha layer
        
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
        let imageRefWithAlpha: CGImageRef = CGBitmapContextCreateImage(offscreenContext)!
        let imageWithAlpha: UIImage = UIImage(CGImage:imageRefWithAlpha)
        return imageWithAlpha
        
    }
    
    
    // Returns a copy of the image with a transparent border of the given size added around its edges.
    // If the image has no alpha layer, one will be added to it.
    func transparentBorderImage(borderSize: CGFloat) -> UIImage
    {
        // If the image does not have an alpha layer, add one
        let image: UIImage = self.imageWithAlpha()
        
        let newRect: CGRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)

        
        // Build a context that's the same dimensions as the new size
        let bitmap: CGContextRef = CGBitmapContextCreate(nil, Int(newRect.size.width), Int(newRect.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), bitmapInfo.rawValue)!
        
        // Draw the image in the center of the context, leaving a gap around the edges
        let imageLocation: CGRect = CGRectMake(borderSize, borderSize, image.size.width, image.size.height)
        CGContextDrawImage(bitmap, imageLocation, self.CGImage)
        let borderImageRef: CGImageRef = CGBitmapContextCreateImage(bitmap)!
        
        // Create a mask to make the border transparent, and combine it with the image
        let maskImageRef: CGImageRef = self.newBorderMask(CGFloat(borderSize), size: newRect.size)
        let transparentBorderImageRef: CGImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef)!
        let transparentBorderImage: UIImage = UIImage(CGImage:transparentBorderImageRef)
        return transparentBorderImage
        
    }
    
    // Creates a mask that makes the outer edges transparent and everything else opaque
    // The size must include the entire mask (opaque part + transparent border)
    // The caller is responsible for releasing the returned reference by calling CGImageRelease
    
    private func newBorderMask(borderSize: CGFloat, size: CGSize) -> CGImageRef
    {
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()!
        
        // Build a context that's the same dimensions as the new size
        let maskContext: CGContextRef = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.None.rawValue)!
        
        // Start with a mask that's entirely transparent
        CGContextSetFillColorWithColor(maskContext, UIColor.blackColor().CGColor)
        CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height))
        
        // Make the inner part (within the border) opaque
        CGContextSetFillColorWithColor(maskContext, UIColor.whiteColor().CGColor)
        CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2))
        
        // Get an image of the context
        let maskImageRef: CGImageRef = CGBitmapContextCreateImage(maskContext)!
        
        return maskImageRef
    }

}