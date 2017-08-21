import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # Operation
//: `Operation` представляет собой 'задачу'
//: ## простейшая `Operation`
//: используется только совместно c `OperationQueue` с помощью метода `addOperation`
let operation1 = {
    print ("Operation 1 started")
    print ("Operation 1 finished")
}

let queue = OperationQueue()
queue.addOperation(operation1)
//: Полноценная `Operation` может быть сконструирована как `BlockOperation` или как пользовательский subclass `Operation`.
//: ## BlockOperation
//: Создаем `BlockOperation` для конкатенации двух строк
var result: String?

let concatenationOperation = BlockOperation {
    result = "💧" + "☂️"
    sleep(2)
}
duration {
    concatenationOperation.start()
}
result

//: Создаем `BlockOperation` с можеством блоков:
let multiPrinter = BlockOperation()
multiPrinter.completionBlock = {
  print("Finished multiPrinting!")
}

multiPrinter.addExecutionBlock {  print("Каждый 🍎"); sleep(2) }
multiPrinter.addExecutionBlock {  print("Охотник 🍊"); sleep(2) }
multiPrinter.addExecutionBlock {  print("Желает 🍋"); sleep(2) }
multiPrinter.addExecutionBlock {  print("Знать 🍏"); sleep(2) }
multiPrinter.addExecutionBlock {  print("Где 💎"); sleep(2) }
multiPrinter.addExecutionBlock {  print("Сидит 🚙"); sleep(2) }
multiPrinter.addExecutionBlock {  print("Фазан 🍆"); sleep(2) }

duration {
  multiPrinter.start()
}
//: ## Subclassing `Operation`
//: Позволяет вам осуществлять большее управление над тем, что делает `Operation`
let inputImage = UIImage(named: "dark_road_small.jpg")
// DONE: Создайте и запустите  FilterOperation

class FilterOperation: Operation {
  var inputImage: UIImage?
  var outputImage: UIImage?
  
  override func main() {
    outputImage = filter(image: inputImage)
  }
}

let filterOp = FilterOperation()
filterOp.inputImage = inputImage

duration {
 filterOp.start()
}
filterOp.outputImage

PlaygroundPage.current.finishExecution()
