import Foundation
//: # Operation Cancellation
//: Очень важно убедиться, что индивидуальные операции реагируют на свойство `isCancelled` и, следовательно, могут быть уничтожены.
//:
//: Тем не менее в дополнение к уничтожению отдельных операциям вы можете уничтожить все операции на определенной очереди операций. Это особенно полезно, если у вас есть набор операций, работающих на единую цель, при этом эта единая цель разделена на независимые операции, которые запускаются параллельно, или представляет собой граф зависимых операций, исполняемых одна за другой.
//:
//: В этой реализации мы достигнем того же самого, что и операция `ArraySumOperation`, которая берет массив кортежей (Int, Int), и, используя функцию медленного сложения slowAdd(), создает массив сумм чисел, составляющих кортеж. Но в нашем случае будет множество отдельных операций `SumOperation`:
class SumOperation: Operation {
  let inputPair: (Int, Int)
  var output: Int?
  
  init(input: (Int, Int)) {
    inputPair = input
    super.init()
  }
  
  override func main() {
    if isCancelled { return }
    output = slowAdd(inputPair)
  }
}
//: Класс `GroupAdd` - это обычный класс, который управляет очередью операций и множеством операций `SumOperation` для того, чтобы посчитать сумму всех пар во входном массиве.
class GroupAdd {
  private let queue = OperationQueue()
  private let appendQueue = OperationQueue()
  var outputArray = [(Int, Int, Int)]()
  
  init(input: [(Int, Int)]) {
    queue.isSuspended = true
    queue.maxConcurrentOperationCount = 2
    appendQueue.maxConcurrentOperationCount = 1
    generateOperations(input)
  }
  
  private func generateOperations(_ numberArray: [(Int, Int)]) {
    for pair in numberArray {
      let operation = SumOperation(input: pair)
      operation.completionBlock = {
     
        // Заметьте: добавляем в массив на очереди операций appendQueue.
        guard let result = operation.output else { return }
        self.appendQueue.addOperation {
          self.outputArray.append((pair.0, pair.1, result))
        }
      }
      queue.addOperation(operation)
    }
  }
  
  func start() {
    queue.isSuspended = false
  }
  
  func cancel() {
    queue.cancelAllOperations()
  }
  
  func wait() {
    queue.waitUntilAllOperationsAreFinished()
  }
}
//: Входной массив
let numberArray = [(1,2), (3,4), (5,6), (7,8), (9,10)]
//: Создаем экземпляр класса `GroupAdd`
let groupAdd = GroupAdd(input: numberArray)
//: Стартуем группу
startClock()
groupAdd.start()
//: __TEST:__ Попробуйте снять комментарий с `cancel()`, чтобы проверить, сработает ли этот метод корректно. После завершения операций останавливаем таймер `stopClock()` и увидим другую длину выходного массива.
sleep(1)
groupAdd.cancel()

groupAdd.wait()
stopClock()
//: Проверяем результат
groupAdd.outputArray
