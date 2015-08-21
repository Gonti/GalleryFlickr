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
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet weak var autorIdLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    var photoData:FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        
        guard let data = photoData else {
            return
        }
        
        if let thumbnail = data.thumbnail {
            imageView.image = thumbnail
        }
        titleLabel.text = data.title
        autorIdLabel.text = data.autorId
        autorLabel.text = data.autor
        linkLabel.text = data.link
        if !data.tags.isEmpty {
            tagsLabel.text = data.tags.reduce("", combine: {
                $0!.isEmpty ? $0! + $1 : $0! + "\n" + $1
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  sender === cancelButton {
            return
        }
        
        if sender === saveButton  {
            guard let image = photoData?.thumbnail else {
                return
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                UIImageWriteToSavedPhotosAlbum(image, segue.destinationViewController, "image:didFinishSavingWithError:contextInfo:", nil)
            }
            
        }
        
    }

}
