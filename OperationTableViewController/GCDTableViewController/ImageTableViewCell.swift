//
//  imageTableViewCell.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/6/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API
    var imageURLString: String? {
        didSet {
            if imageURLString != nil {
                updateImageViewWithImage(nil)
            }
        }
    }
    
    func updateImageViewWithImage(_ image: UIImage?) {
        if let image = image {
            tImage.image = image
            tImage.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.tImage.alpha = 1.0
                self.spinner.alpha = 0
            }, completion: { _ in
                self.spinner.stopAnimating()
            })
            
        } else {
            tImage.image = nil
            tImage.alpha = 0
            spinner.alpha = 1.0
            spinner.startAnimating()
        }
    }
}
 
