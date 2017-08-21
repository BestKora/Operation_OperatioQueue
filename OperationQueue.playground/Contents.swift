import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # OperationQueue
//: `OperationQueue` отвечает за планирование и запуск группы операций по умолчанию на background.
//: ## Создание очереди операций
//: Создание очереди операций очень просто с использованием default initializer; вы также можете установить максимальное число операций, которые будут выполняться одновременно, а также задать очередь, на которой будут выполняться операции
// Создаем пустую очередь printerQueue
let printerQueue = OperationQueue()

//printerQueue.maxConcurrentOperationCount = 2
//printerQueue.underlyingQueue = DispatchQueue(label: "...", qos: .userInitiated, attributes:.concurrent)
//: ## Добавляем операции `Operations` на очередь операций
/*: Операции `Operations` можно добавлять на очередь напрямую как замыкания
 - ВАЖНО:
 Добавление операций в очередь действительно "ничего не стоит"; хотя операции начинают выполняться как только окажутся в очереди, добавление их происходит полностью асинхронно.
 \
 Вы можете это обнаружить по результатам работы функции `duration` :
 */
let concatenationOperation = BlockOperation {
    print ( "-------💧" + "☂️")
    sleep(2)
}
concatenationOperation.qualityOfService = .userInitiated

// DONE: Добавляем 5 операций на очередь printerQueue

duration {
  
  printerQueue.addOperation {  print("Каждый 🍎"); sleep(2) }
  printerQueue.addOperation {  print("Охотник 🍊");sleep(2) }
  printerQueue.addOperation {  print("Желает 🍋"); sleep(2) }
  printerQueue.addOperation {  print("Знать 🍏");  sleep(2) }
  printerQueue.addOperation {  print("Где 💎");    sleep(2) }
  printerQueue.addOperation {  print("Сидит 🚙");  sleep(2) }
  printerQueue.addOperation {  print("Фазан 🍆");  sleep(2) }
  
  printerQueue.addOperation(concatenationOperation)

}

// DONE: Измеряем длительность всех операций
duration {
  printerQueue.waitUntilAllOperationsAreFinished()
}
//: ## Фильтрация массива изображений
//: Теперь более реальный пример.
// Исходные изображения
let images = ["city", "dark_road", "train_day", "train_dusk", "train_night"].map { UIImage(named: "\($0).jpg") }

// Отфильтрованные изображения
var filteredImages = [UIImage]()
//: Создаем очередь filterQueue с помощью default initializer:
let filterQueue = OperationQueue()
//: Создаем последовательную очередь (serial queue) appendQueue для добавления элемента к массиву:
let appendQueue = OperationQueue()
appendQueue.maxConcurrentOperationCount = 1
//: Создаем операцию фильтрации для каждого изображения, добавляя `completionBlock`:
for image in images {

  let filterOp = FilterOperation()
  filterOp.inputImage = image
  filterOp.completionBlock = {
    guard let output = filterOp.outputImage else { return }
    appendQueue.addOperation {
      filteredImages.append(output)
    }
  }
  filterQueue.addOperation(filterOp)
}
//: Необходимо дождаться, пока закончатся операции на очереди прежде, чем проверять результаты
// Ждем...
duration {
filterQueue.waitUntilAllOperationsAreFinished()
}
//: Проверяем отфильтрованные изображения
filteredImages[0]

filteredImages[1]
filteredImages[4]
//filterOp.outputImage
PlaygroundPage.current.finishExecution()
