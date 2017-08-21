import UIKit

public func asyncImageLoad(imageURL: URL, completion:@escaping (UIImage?) -> () ) {
    let task = URLSession.shared.dataTask(with: imageURL){
        (data, response, error) in
        if let data = data {
            completion(UIImage(data: data))
        }
    }
    task.resume()
}
