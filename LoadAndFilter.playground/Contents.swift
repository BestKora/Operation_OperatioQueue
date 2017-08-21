import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: ## Dependencies
//: Операция загрузки `ImageLoadOperation` уже нам знакома:
class ImageLoadOperation: AsyncOperation {
    var urlString: String?
    var outputImage: UIImage?
    
    init(urlString: String?) {
        self.urlString = urlString
        super.init()
    }
    override func main() {
        asyncImageLoad (urlString: self.urlString) { [unowned self] (image) in
            self.outputImage = image
            self.state = .finished
        }
    }
}

//:  Передача данных в зависимую операцию c помощью протокола
protocol ImagePass {
    var image: UIImage? { get }
}

extension ImageLoadOperation: ImagePass {
  var image: UIImage? { return outputImage }
}
//: Операция фильтрации `FilterOperation`:
class FilterOperation: Operation {
    var outputImage: UIImage?
    private let _inputImage: UIImage?
    
    init(_ image: UIImage?) {
        _inputImage = image
        super.init()
    }

    var inputImage: UIImage? {
        // Определяем, задан ли у операции inputImage
        // Если НЕТ, то анализируем dependencies,
        // которые "подтверждают" протокол ImagePass
        var image: UIImage?
        if let inputImage = _inputImage {
            image = inputImage
        } else if let dataProvider = dependencies
            .filter({ $0 is ImagePass })
            .first as? ImagePass {
            image = dataProvider.image
        }
        return image
    }

    override func main() {
        outputImage = filterImage(image: inputImage)
    }
}
//: Определяем две операции:
let urlString = "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg"
let imageLoad = ImageLoadOperation(urlString:urlString )
let filter = FilterOperation(nil)
//: Устанавливаем зависимость между операциями imageLoad и filter:
filter.addDependency(imageLoad)
//: Добавляем обе операции в очередь операций:
let queue = OperationQueue()
queue.addOperations([imageLoad, filter], waitUntilFinished: true)
//: И смотрите, что у нас на выходе:
imageLoad.outputImage
filter.outputImage

sleep(3)
//PlaygroundPage.current.finishExecution()
