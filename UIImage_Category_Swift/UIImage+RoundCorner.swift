//
//  UIImage+RoundCorner.swift
//
//  Created by Rupesh Kumar on 10/23/15.
//  Copyright © 2015 Rupesh Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
        
    // Creates a copy of this image with rounded corners
    // If borderSize is non-zero, a transparent border of the given size will also be added
    // Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners
    func roundedCornerImage(cornerSize: CGFloat, borderSize: UInt) -> UIImage
    {
        // If the image does not have an alpha layer, add one
        let image: UIImage = self.imageWithAlpha()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)

        // Build a context that's the same dimensions as the new size
        let context: CGContextRef! = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), CGImageGetBitsPerComponent(image.CGImage), CGImageGetBytesPerRow(image.CGImage), CGImageGetColorSpace(image.CGImage),bitmapInfo.rawValue)
        
        // Create a clipping path with rounded corners
        CGContextBeginPath(context)
        let rect :CGRect = CGRectMake(CGFloat(borderSize), CGFloat(borderSize), image.size.width - CGFloat(borderSize * 2), image.size.height - CGFloat(borderSize * 2))
        self.addRoundedRectToPath(rect, context:context!, ovalWidth: cornerSize, ovalHeight: cornerSize)
        CGContextClosePath(context)
        CGContextClip(context)
        
        // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage)
        
        // Create a CGImage from the context
        let clippedImage: CGImageRef = CGBitmapContextCreateImage(context)!
        
        // Create a UIImage from the CGImage
        let roundedImage: UIImage = UIImage(CGImage: clippedImage)
        return roundedImage
    }
    
    // Adds a rectangular path to the given context and rounds its corners by the given extents
    // Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners
    private func addRoundedRectToPath(rect: CGRect, context: CGContextRef, ovalWidth: CGFloat, ovalHeight: CGFloat)
    {
        if ovalWidth == 0 || ovalHeight == 0
        {
            CGContextAddRect(context, rect)
            return
        }
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextScaleCTM(context, ovalWidth, ovalHeight)
        let fw: CGFloat = CGRectGetWidth(rect) / ovalWidth
        let fh: CGFloat = CGRectGetHeight(rect) / ovalHeight
        CGContextMoveToPoint(context, fw, fh / 2)
        CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1)
        CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1)
        CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1)
        CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1)
        CGContextClosePath(context)
        CGContextRestoreGState(context)
    }
    
    

    
}
