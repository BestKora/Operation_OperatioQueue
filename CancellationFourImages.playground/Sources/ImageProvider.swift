//
//  ImageProvider.swift
//  ConcurrencyDemo
//
//  Created by Tatiana Kornilova on 2/8/17.
//  Copyright © 2017 Hossam Ghareeb. All rights reserved.
//
/*import UIKit

public class ImageProvider {
private var operationQueue = OperationQueue ()
    
   public init(imageURLString: String,completion: @escaping (UIImage?) -> ()) {
        operationQueue.isSuspended = true
        operationQueue.maxConcurrentOperationCount = 2
        
        if let imageURL = URL(string: imageURLString){
            
            // Создаем operations
            let dataLoad = ImageLoadOperation(url: imageURL)
            let filter = Filter(image: nil)
            let output = ImageOutputOperation(){image in
                OperationQueue.main.addOperation {completion (image) }}
            
            let operations = [dataLoad, filter, output]
            
            // Добавляем dependencies
            filter.addDependency(dataLoad)
            output.addDependency(filter)
            
            operationQueue.addOperations(operations, waitUntilFinished: false)
        }
    }
   public func start() {
        operationQueue.isSuspended = false
    }
    
   public func cancel() {
        operationQueue.cancelAllOperations()
    }
    public func wait() {
        operationQueue.waitUntilAllOperationsAreFinished()
    }
}
*/

