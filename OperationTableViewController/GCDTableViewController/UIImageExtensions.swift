/*
 File: UIImage+ImageEffects.m
 Abstract: This is a category of UIImage that adds methods to apply blur and tint effects to an image. This is the code you’ll want to look out to find out how to use vImage to efficiently calculate a blur.
 Version: 1.0
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 EA1002
 5/3/2013
 */

//
//  UIImage.swift
//  Today
//
//  Created by Alexey Globchastyy on 15/09/14.
//  Copyright (c) 2014 Alexey Globchastyy. All rights reserved.
//


import UIKit
import Accelerate

extension UIImage {
  public func applyBlurWithRadius(_ blurRadius: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
    // Check pre-conditions.
    if (size.width < 1 || size.height < 1) {
      print("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
      return nil
    }
    if self.cgImage == nil {
      print("*** error: image must be backed by a CGImage: \(self)")
      return nil
    }
    if maskImage != nil && maskImage!.cgImage == nil {
      print("*** error: maskImage must be backed by a CGImage: \(String(describing: maskImage))")
      return nil
    }
    
    let __FLT_EPSILON__ = CGFloat(Float.ulpOfOne)
    let screenScale = UIScreen.main.scale
    let imageRect = CGRect(origin: CGPoint.zero, size: size)
    var effectImage = self
    
    let hasBlur = blurRadius > __FLT_EPSILON__
    
    if hasBlur {
      func createEffectBuffer(_ context: CGContext) -> vImage_Buffer {
        let data = context.data
        let width = vImagePixelCount(context.width)
        let height = vImagePixelCount(context.height)
        let rowBytes = context.bytesPerRow
        
        return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
      }
      
      UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
      let effectInContext = UIGraphicsGetCurrentContext()!
      
      effectInContext.scaleBy(x: 1.0, y: -1.0)
      effectInContext.translateBy(x: 0, y: -size.height)
      effectInContext.draw(self.cgImage!, in: imageRect)
      
      var effectInBuffer = createEffectBuffer(effectInContext)
      
      
      UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
      let effectOutContext = UIGraphicsGetCurrentContext()!
      
      var effectOutBuffer = createEffectBuffer(effectOutContext)
      
      
      if hasBlur {
        // A description of how to compute the box kernel width from the Gaussian
        // radius (aka standard deviation) appears in the SVG spec:
        // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
        //
        // For larger values of 's' (s >= 2.0), an approximation can be used: Three
        // successive box-blurs build a piece-wise quadratic convolution kernel, which
        // approximates the Gaussian kernel to within roughly 3%.
        //
        // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
        //
        // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
        //
        
        let inputRadius = blurRadius * screenScale
        var radius = UInt32(floor(Double(inputRadius * 0.75 * sqrt(2.0 * .pi) + 0.5)))
        if radius % 2 != 1 {
          radius += 1 // force radius to be odd so that the three box-blur methodology works.
        }
        
        let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
        
        vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
        vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
        vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
      }
      
      effectImage = UIGraphicsGetImageFromCurrentImageContext()!
      
      UIGraphicsEndImageContext()
      UIGraphicsEndImageContext()
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
    let outputContext = UIGraphicsGetCurrentContext()
    outputContext?.scaleBy(x: 1.0, y: -1.0)
    outputContext?.translateBy(x: 0, y: -size.height)
    
    // Draw base image.
    outputContext?.draw(self.cgImage!, in: imageRect)
    
    // Draw effect image.
    if hasBlur {
      outputContext?.saveGState()
      if let image = maskImage {
        //CGContextClipToMask(outputContext, imageRect, image.CGImage);
        let effectCGImage = effectImage.cgImage?.masking(image.cgImage!)
        if let effectCGImage = effectCGImage {
          effectImage = UIImage(cgImage: effectCGImage)
        }
      }
      outputContext?.draw(effectImage.cgImage!, in: imageRect)
      outputContext?.restoreGState()
    }
    
    // Output image is ready.
    let outputImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return outputImage
  }
}
