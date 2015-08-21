//
//  FlickrGalleryCollectionViewController.swift
//  AnotherPhotoGallery
//
//  Created by Tomasz Gontarz on 21/08/15.
//  Copyright © 2015 Tomasz Gontarz. All rights reserved.
//

import UIKit

class FlickrGalleryCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "FlickrCell"
    private let detailsSegueIdentifier = "ShowDetails"
    
    private var results = [FlickrResults]()
    private let flickr = Flickr()
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    @IBOutlet weak var appendMorePhotosButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPhotos()
    }
    
    func displayPhotos() {
        appendMorePhotosButton.enabled = false
        showIdicator()
        flickr.requestFlickr { results, error in
            self.appendMorePhotosButton.enabled = true
            if error != nil {
                print("Error: \(error!)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.hideIndictaor()
                    self.showConnectionAlert()
                })
                return
            }
            
            if let results = results {
                self.results.append(results)
                self.collectionView?.reloadData()
            }
            self.hideIndictaor()
        }
    }
    
    func showConnectionAlert() {
        let alertController = UIAlertController(title: "Error", message: "Connection Error", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) { }
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
        return results[indexPath.section].results[indexPath.row]
    }
    
    func showIdicator() {
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
    }
    
    func hideIndictaor() {
        activityIndicator.removeFromSuperview()
    }
    
    @IBAction func appendMorePhotos(sender: UIButton) {
        displayPhotos()
    }
    
    @IBAction func unwindToGalery(sender: UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let navigation = segue.destinationViewController as! UINavigationController
            let photoDetailViewController = navigation.viewControllers.first as! FlickrPhotoDetailsViewController
            
            // Get the cell that generated this segue.
            if let selectedImageCell = sender as? FlickrGalleryCollectionViewCell {
                let indexPath = collectionView!.indexPathForCell(selectedImageCell)!
                let selectedPhoto = photoForIndexPath(indexPath)
                photoDetailViewController.photoData = selectedPhoto
            }
        }
    }
    
}

extension FlickrGalleryCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return results.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results[section].results.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrGalleryCollectionViewCell
        let flickrPhoto = photoForIndexPath(indexPath)
        cell.photoView.image = flickrPhoto.thumbnail
        
        return cell
    }
}

extension FlickrGalleryCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            let flickrPhoto =  photoForIndexPath(indexPath)
            if var size = flickrPhoto.thumbnail?.size {
                size.width = size.width / 3
                size.height = size.height / 3
                return size
            }
            return CGSize(width: 100, height: 100)
    }
}
