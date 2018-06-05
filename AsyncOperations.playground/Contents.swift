import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: ## AsyncOperation: Превращение Asynchronous Function в Operation
/*:
 Для СИНХРОННЫХ задач мы можем создать subclass `Operation` путем переопределения метода `main()`.
 
 `AsyncOperation` - это пользовательский subclass `Operation`, который управляет изменением состояния операции автоматически. Для того, чтобы вы смогли воспользоваться  этим subclass `AsyncOperation` и превратить свою АСИНХРОННУЮ функцию в `Operation`, вам нужно:
 
 1. Создать subclass класса `AsyncOperation`.
 2. Переопределить (override) `main()` и вызвать свою АСИНХРОННУЮ функцию.
 3. Изменить значение свойства `state` вашего subclass `AsyncOperation` на `.finished` в асинхронном callback.
 
 - ВАЖНО:
 Шаг 3 этой инструкции является *чрезвычайно* важным - именно так вы сообщаете очереди операций `OperationQueue`, что запущенная операция закончилась. В противном случае она никогда не закончится.
 */
class AsyncOperation: Operation {
    
  // Определяем перечисление enum State со свойством keyPath
  enum State: String {
    case ready, executing, finished
    
    fileprivate var keyPath: String {
      return "is" + rawValue.capitalized
    }
  }
  
  // Помещаем в subclass свойство state типа State
  var state = State.ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }
}
/*:
 Каждое свойство состояния, наследуемое из класса `Operation` переопределяем таким образом, чтобы "подменить" их новым свойством `state`.
 
 Свойство `asynchronous` нужно установить в `true`, чтобы сообщить системе, что мы будем управлять состоянием операции вручную.
 
 Мы также вынуждены переопределить методы `start()` и `cancel()` для того, чтобы "имплантировать" новое свойство `state`.
*/
extension AsyncOperation {
  // Переопределения для Operation
  override var isReady: Bool {
    return super.isReady && state == .ready
  }
  
  override var isExecuting: Bool {
    return state == .executing
  }
  
  override var isFinished: Bool {
    return state == .finished
  }
  
  override var isAsynchronous: Bool {
    return true
  }
  
  override func start() {
    if isCancelled {
      state = .finished
      return
    }
    main()
    state = .executing
  }
  
  override func cancel() {
    state = .finished
  }
  
}
/*:
 Теперь "обернуть" АСИНХРОННУЮ функцию в операцию `AsyncOperation` проще простого - переопределяем метод `main()`, не забывая установить свойству `state` в  замыкании completion значение `.finished`:
 */
class SumOperation: AsyncOperation {
  // Определяем: Properties, init, main
  let lhs: Int
  let rhs: Int
  var result: Int?
  
  init(lhs: Int, rhs: Int) {
    self.lhs = lhs
    self.rhs = rhs
    super.init()
  }
  
  override func main() {
    asyncAdd(lhs: lhs, rhs: rhs) { result in
      self.result = result
      self.state = .finished
    }
  }
}
//: Используем `OperationQueue` и массив пар чисел:
let additionQueue = OperationQueue()

let input = [(1,5), (5,8), (6,1), (3,9), (6,12), (1,0)]

for (lhs, rhs) in input {
  // Создаем объект SumOperation
  let operation = SumOperation(lhs: lhs, rhs: rhs)
  operation.completionBlock = {
    guard let result = operation.result else { return }
    print("\(lhs) + \(rhs) = \(result)")
  }
  
  // Добавляем SumOperation на очередь additionQueue
  additionQueue.addOperation(operation)
}


class ImageLoadOperation: AsyncOperation {
    var url: URL?
    var outputImage: UIImage?
    
    init(url: URL?) {
        self.url = url
        super.init()
    }

    override func main() {
        if let imageURL = url {
            asyncImageLoad(imageURL: imageURL) { [unowned self]  image in
                self.outputImage = image
                self.state = .finished
            }
        }
    }
}

//------------------------------------------------------------------------------
var view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
var eiffelImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
eiffelImage.backgroundColor = UIColor.yellow
eiffelImage.contentMode = .scaleAspectFit
view.addSubview(eiffelImage)
//------------------------------------------------------------------------------

PlaygroundPage.current.liveView = view

let imageURL = URL(string:"http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg")

// Создаем операцию загрузки изображения operationLoad

let operationLoad = ImageLoadOperation(url: imageURL)

operationLoad.completionBlock = {
    OperationQueue.main.addOperation {
        eiffelImage.image = operationLoad.outputImage
    }
}

// Добавляем operationLoad на очередь loadQueue

let loadQueue = OperationQueue()
loadQueue.addOperation(operationLoad)
loadQueue.waitUntilAllOperationsAreFinished()
sleep(5)
operationLoad.outputImage
//PlaygroundPage.current.finishExecution()
