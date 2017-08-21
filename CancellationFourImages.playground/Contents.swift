import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//: 'ImageProvider' - это обычный класс, который управляет очередью операций и набор операций, работающих на единую цель, представляющую собой граф зависимых операций, исполняемых одна за другой.
class ImageProvider {
    
    private var operationQueue = OperationQueue ()
    
    init(imageURLString: String,completion: @escaping (UIImage?) -> ()) {
        operationQueue.isSuspended = true
        operationQueue.maxConcurrentOperationCount = 2
        
        guard let imageURL = URL(string: imageURLString) else {return}
            
            // Создаем операции
            let dataLoad = ImageLoadOperation(url: imageURL)
            let filter = Filter(image: nil)
            let postProcess = PostProcessImageOperation(image: nil)
            let output = ImageOutputOperation(){image in
                OperationQueue.main.addOperation {completion (image) }}
            
            let operations = [dataLoad, filter, postProcess, output]
            
            // Добавляем dependencies
            filter.addDependency(dataLoad)
            postProcess.addDependency(filter)
            output.addDependency(postProcess)
            operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
   func start() {
        operationQueue.isSuspended = false
    }
    
   func cancel() {
        operationQueue.cancelAllOperations()
    }
    
    func wait() {
        operationQueue.waitUntilAllOperationsAreFinished()
    }
}


var view = FourImages(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.backgroundColor = UIColor.red

let imageURLs = ["http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
                 "http://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg",
                 "http://bestkora.com/IosDeveloper/wp-content/uploads/2016/12/Screen-Shot-2017-01-17-at-9.33.52-PM.png",
                 "http://www.picture-newsletter.com/arctic/arctic-12.jpg" ]
var images = [UIImage] ()
var ip: [ImageProvider] = []
PlaygroundPage.current.liveView = view

//: ### Формируем массив  'ip : [ImageProvider]' провайдеров для загрузки и фильтрации 4-х изображений

for i in 0...3 {
    ip.append(ImageProvider(imageURLString: imageURLs[i]) { (image) in
        OperationQueue.main.addOperation {view.ivs[i].image = image; print (i)}
    })

}
//: ### Стартуем загрузку изображений
startClock()
for ipx in ip {
    ipx.start()
}

//: ### Удаляем операции загрузки изображений спустя некоторое время
sleep (6)
for ipx in ip {
    ipx.cancel()
}
stopClock()

//: ### Ждем окончания загрузки
/*for ipx in ip {
    ipx.wait()
}
stopClock()
*/
//PlaygroundPage.current.finishExecution()
// Остановите Playground вручную, но изображение исчезнет
