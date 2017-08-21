//
//  ImageTableViewController.swift
//  GCDTableViewController
//
//  Created by Tatiana Kornilova on 1/20/17.
//  Copyright © 2017 Tatiana Kornilova. All rights reserved.
//

import UIKit

class ImageTableViewController: UITableViewController {
    var imageURLs: [String] =
        ["http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
         "http://adriatic-lines.com/wp-content/uploads/2015/04/canal-of-Venice.jpg",
         "http://bestkora.com/IosDeveloper/wp-content/uploads/2016/12/Screen-Shot-2017-01-17-at-9.33.52-PM.png",
         "http://www.picture-newsletter.com/arctic/arctic-02.jpg",
         "http://www.planetware.com/photos-large/F/france-paris-eiffel-tower.jpg",
         "http://www.picture-newsletter.com/arctic/arctic-16.jpg",
         "http://www.picture-newsletter.com/arctic/arctic-15.jpg",
         "http://www.picture-newsletter.com/arctic/arctic-12.jpg"]
    
    var imageProviders = Set<ImageProvider>()

      // MARK: - Table view data source

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageOperation",
                                                                   for: indexPath)

        if let cell = cell as? ImageTableViewCell {
            cell.imageURLString =  imageURLs [indexPath.row]
        }
        return cell
    }
}

extension ImageTableViewController {
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImageTableViewCell else { return }
        
        let imageProvider = ImageProvider(imageURLString:
        imageURLs[(indexPath as NSIndexPath).row]) {
            image in
            OperationQueue.main.addOperation {
                cell.updateImageViewWithImage(image)
            }
        }
        imageProviders.insert(imageProvider)
    }
    
    override func tableView(_ tableView: UITableView,
                            didEndDisplaying cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImageTableViewCell else { return }
        for provider in
            imageProviders.filter({ $0.imageURLString == cell.imageURLString }){
            
            provider.cancel()
            imageProviders.remove(provider)
        }
    }
}

