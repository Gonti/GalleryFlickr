//
//  FlickrUtilities.swift
//  AnotherPhotoGallery
//
//  Created by Tomasz Gontarz on 21/08/15.
//  Copyright © 2015 Tomasz Gontarz. All rights reserved.
//

import Foundation
import UIKit

class Flickr {
    
    private let URLString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"
    
    func requestFlickr(completion: (results: FlickrResults?, error: ErrorType?) -> Void) {
        
        guard let recentURL = NSURL(string: URLString) else {
            let URLError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Wrong url string"])
            completion(results: nil, error: URLError)
            return
        }
        
        let recentRequest = NSURLRequest(URL: recentURL)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        // To Do: Use Alamofire library instead
        
        let requestDataTask = session.dataTaskWithRequest(recentRequest) { data, response, error in
            
            if let error = error {
                completion(results: nil, error: error)
                return
            }
            
            let resultsDictionary:NSDictionary?
            
            guard let data = data, fixedData = self.fixData(data)  else {
                let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "Cant fix API response"])
                completion(results: nil, error: APIError)
                return
            }
            
            do {
                resultsDictionary = try NSJSONSerialization.JSONObjectWithData(fixedData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                print(resultsDictionary)
            }
            catch {
                completion(results: nil, error: error)
                return
            }
            
            // To Do: Use SwiftyJSON library instead
            
            let photosReceived = resultsDictionary!["items"] as! [NSDictionary]
            
            let flickrPhotos : [FlickrPhoto] = photosReceived.map {
                photoDictionary in
                
                let title = photoDictionary["title"] as? String ?? ""
                let link = photoDictionary["link"] as? String ?? ""
                let media = photoDictionary["media"] as? [String:String] ?? [String:String]()
                let date_taken = photoDictionary["date_taken"] as? String ?? ""
                let description = photoDictionary["description"] as? String ?? ""
                let published = photoDictionary["published"] as? String ?? ""
                let autor = photoDictionary["autor"] as? String ?? ""
                let autor_id = photoDictionary["autor_id"] as? String ?? ""
                
                let tags = (photoDictionary["tags"] as? String ?? "").characters.split { $0 == " "}.map { String($0) }
                
                let flickrPhoto = FlickrPhoto(title: title,
                    link: link,
                    media: media,
                    date_taken: date_taken,
                    description: description,
                    published: published,
                    autor: autor,
                    autor_id: autor_id,
                    tags: tags)
                
                if let imageUrl = flickrPhoto.flickrImageURL(), imageData = NSData(contentsOfURL: imageUrl)  {
                    flickrPhoto.thumbnail = UIImage(data: imageData)
                }
                
                return flickrPhoto
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(results: FlickrResults(results: flickrPhotos), error: nil)
            })
            
        }
        
        requestDataTask.resume()
    }
    
    // Helper method to fix broken json data from Flickr public api
    
    func fixData(data:NSData) -> NSData? {
        
        guard let jsonString = NSString(data: data, encoding:NSUTF8StringEncoding) else {
            return nil
        }
        
        let newString = jsonString.stringByReplacingOccurrencesOfString("\\'", withString: "'")
        
        guard let fixedData = newString.dataUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }
        
        return fixedData
    }
}
