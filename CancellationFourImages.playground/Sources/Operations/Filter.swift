import UIKit

public class Filter : ImageTakeOperation {
    
    override public func main() {
        if isCancelled { return }
        guard let inputImage = inputImage else { return }
        
        if isCancelled { return }
        let mask = topAndBottomGradient(inputImage.size)
        
        if isCancelled { return }
        outputImage = inputImage.applyBlurWithRadius(6, maskImage: mask)
    }
}
