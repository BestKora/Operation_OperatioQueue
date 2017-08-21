
import UIKit

public func filter(image: UIImage?) -> UIImage? {
    guard let image = image else { return .none }
    sleep(1)
    let mask = topAndBottomGradient(size: image.size)
    return image.applyBlur(radius: 6, maskImage: mask)
}

func filterAsync(image: UIImage?, callback: @escaping (UIImage?) ->()) {
    OperationQueue().addOperation {
        let result = filter(image: image)
        callback(result)
    }
}

