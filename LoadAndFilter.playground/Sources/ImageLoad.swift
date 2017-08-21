import UIKit

public func asyncImageLoad(urlString: String?,callback: @escaping (UIImage?) -> ()) {
    guard let urlString = urlString,
          let imageURL = URL(string: urlString) else { return callback (nil) }
    
    let task = URLSession.shared.dataTask(with: imageURL){
        (data, response, error) in
        if let data = data {
            callback (UIImage(data: data))
        }
    }
    task.resume()
}
