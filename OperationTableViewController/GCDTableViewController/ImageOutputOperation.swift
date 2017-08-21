import UIKit

public class ImageOutputOperation: ImageTakeOperation {
    
    private let completion: (UIImage?) -> ()
    
    public init(completion: @escaping (UIImage?) -> ()) {
        self.completion = completion
        super.init(image: nil)
    }
    
    override public func main() {
        if isCancelled { completion(nil)}
        completion(inputImage)
    }
}


