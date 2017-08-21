/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import CoreImage
import UIKit


// This is an implementation of a Core Image filter chain that returns a CGImage
// backed UIImage. This is not usually the best approach - CIImage-backed
// UIImages are more optimised to display straight on screen.
func postProcessImage(_ image: UIImage) -> UIImage {
  
  guard let inputImage = CIImage(image: image) else { return image }
  
  // Create filter chain
  guard let photoFilter = CIFilter(name: "CIPhotoEffectInstant",
      withInputParameters: ["inputImage" : inputImage]),
    let photoOutput = photoFilter.outputImage,
    let vignetteFilter = CIFilter(name: "CIVignette",
      withInputParameters: ["inputRadius" : 1.75, "inputIntensity" : 1.0, "inputImage": photoOutput]),
    let filterOutput = vignetteFilter.outputImage else { return image }
  
  let ciContext = CIContext(options: nil)
  
  let cgImage = ciContext.createCGImage(filterOutput, from: inputImage.extent)
  return UIImage(cgImage: cgImage!)
}
