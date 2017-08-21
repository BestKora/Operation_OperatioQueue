import Foundation
import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: ## Operation Cancellation
//: Операция `ArraySumOperation` берет массив кортежей `(Int, Int)`, использует функцию медленного сложения `slowAdd()`, представленную в __Sources__ и создает массив сумм чисел, составляющих кортеж.
class ArraySumOperation: Operation {
    let inputArray: [(Int, Int)]
    var outputArray = [Int]()
    
    init(input: [(Int, Int)]) {
        inputArray = input
        super.init()
    }
    
    override func main() {
        for pair in inputArray {
            if isCancelled { return }
            outputArray.append (slowAdd(pair))
        }
    }
}
//: Другая операция `AnotherArraySumOperation` использует уже готовую функцию формирования из массива кортежей массива сумм чисел, составляющих кортеж
class AnotherArraySumOperation: Operation {
  let inputArray: [(Int, Int)]
  var outputArray: [Int]?
  
  init(input: [(Int, Int)]) {
    inputArray = input
    super.init()
  }
  
  override func main() {
    // DONE: Fill this in
    outputArray = slowAddArray(inputArray) {
      progress in
      print("\(progress*100)% of the array processed")
      return !self.isCancelled
    }
  }
}
//: Входной массив
let numberArray = [(1,2), (3,4), (5,6), (7,8), (9,10)]
//: Операция `sumOperation` и очередь операций `queue`
let sumOperation = AnotherArraySumOperation(input: numberArray)
let queue = OperationQueue()
//: Добавляем операцию в очередь операций и запускаем таймер. Таймер в дальнейшем поможет нам отрегулировать время "ожидания", спустя которое мы сможем проверить реакцию `sumOperation` на вызов метода `cancel()`.
startClock()
queue.addOperation(sumOperation)
//:  Немного "ожидаем" с помощью sleep(...), а затем удаляем операцию
sleep(4)
sumOperation.cancel()

sumOperation.completionBlock = {
  stopClock()
  sumOperation.outputArray
  PlaygroundPage.current.finishExecution()
}
