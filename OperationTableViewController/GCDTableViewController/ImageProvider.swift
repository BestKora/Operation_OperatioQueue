//
//  ImageProvider.swift
//  ConcurrencyDemo
//
//  Created by Tatiana Kornilova on 2/8/17.
//

import UIKit
class ImageProvider {
    
    private var operationQueue = OperationQueue ()
    let imageURLString: String
    
    init(imageURLString: String,completion: @escaping (UIImage?) -> ()) {
        self.imageURLString = imageURLString
        operationQueue.maxConcurrentOperationCount = 2
        
        guard let imageURL = URL(string: imageURLString) else {return}
        
        // Создаем операции
        let dataLoad = ImageLoadOperation(url: imageURL)
        let filter = Filter(image: nil)
        let output = ImageOutputOperation(completion: completion)
        
        let operations = [dataLoad, filter, output]
        
        // Добавляем dependencies
        filter.addDependency(dataLoad)
        output.addDependency(filter)
        
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
    }
    
  }

extension ImageProvider: Hashable {
    var hashValue: Int {
        return (imageURLString).hashValue
    }
}

func ==(lhs: ImageProvider, rhs: ImageProvider) -> Bool {
    return lhs.imageURLString == rhs.imageURLString
}


