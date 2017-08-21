
import UIKit

public class ImageLoadOperation: AsyncOperation {
    private var url: URL?
    fileprivate var outputImage: UIImage?
    
    public init(url: URL?) {
        self.url = url
        super.init()
    }
    
    override public func main() {
        if self.isCancelled { return}
        guard let imageURL = url else {return}
        let task = URLSession.shared.dataTask(with: imageURL){(data, response, error) in
            if self.isCancelled { return}
            if let data = data,
                let imageData = UIImage(data: data) {
                if self.isCancelled { return }
                self.outputImage = imageData
            }
            self.state = .finished
        }
        task.resume()
    }
}


extension ImageLoadOperation: ImagePass {
    var image: UIImage? {
        return outputImage
    }
}


