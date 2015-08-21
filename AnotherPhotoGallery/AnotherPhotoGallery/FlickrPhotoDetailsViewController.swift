//
//  FlickrPhotoDetailsViewController.swift
//  AnotherPhotoGallery
//
//  Created by Tomasz Gontarz on 21/08/15.
//  Copyright © 2015 Tomasz Gontarz. All rights reserved.
//

import UIKit

import UIKit

class FlickrPhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet weak var autorIdLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    var photoData:FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        if let thumbnail = photoData?.thumbnail {
            imageView.image = thumbnail
        }
        titleLabel.text = photoData?.title
        autorIdLabel.text = photoData?.autorId
        autorLabel.text = photoData?.autor
        linkLabel.text = photoData?.link
        view.layoutIfNeeded()
    }
    
}
