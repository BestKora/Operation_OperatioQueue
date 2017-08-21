import UIKit

protocol ImagePass {
    var image: UIImage? { get }
}

open class ImageTakeOperation: Operation {
    var outputImage: UIImage?
    private let _inputImage: UIImage?
    
    public init(image: UIImage?) {
        _inputImage = image
        super.init()
    }
    
    public var inputImage: UIImage? {
        var image: UIImage?
        if let inputImage = _inputImage {
            image = inputImage
        } else if let dataProvider = dependencies
            .filter({ $0 is ImagePass })
            .first as? ImagePass {
            image = dataProvider.image
        }
        return image
    }
}

extension ImageTakeOperation: ImagePass {
    var image: UIImage? {
        return outputImage
    }
}
