//
//  FlickrDataModel.swift
//  AnotherPhotoGallery
//
//  Created by Tomasz Gontarz on 21/08/15.
//  Copyright © 2015 Tomasz Gontarz. All rights reserved.
//

import Foundation
import UIKit

struct FlickrResults {
    let results : [FlickrPhoto]
}

class FlickrPhoto {
    
    let title: String
    let link: String
    let media: [String:String]
    let date_taken: String
    let description: String
    let published: String
    let autor: String
    let autorId: String
    let tags: [String]
    var thumbnail: UIImage?
    var largeImage: UIImage?
    
    
    
    init(title: String, link: String, media: [String:String], date_taken: String, description: String, published: String, autor: String, autor_id: String, tags: [String]) {
        self.title = title
        self.link = link
        self.media = media
        self.date_taken = date_taken
        self.description = description
        self.published = published
        self.autor = autor
        self.autorId = autor_id
        self.tags = tags
    }
    
    func flickrImageURL(size:String = "m") -> NSURL? {
        guard let urlString = media[size] else {
            return nil
        }
        
        return NSURL(string: urlString)
    }
    
}
