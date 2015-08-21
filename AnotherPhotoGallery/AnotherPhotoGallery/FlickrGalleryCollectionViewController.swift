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
    

    @IBOutlet weak var appendMorePhotosButton: UIBarButtonItem!
    @IBOutlet weak var searchTagsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPhotos()
    }
    
    func displayPhotos() {
        appendMorePhotosButton.enabled = false
        searchTagsTextField.resignFirstResponder()
        searchTagsTextField.userInteractionEnabled = false
        
        showIdicator()
        flickr.requestFlickr { results, error in
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
            self.appendMorePhotosButton.enabled = true
            self.searchTagsTextField.userInteractionEnabled = true
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
    
    func image(image: UIImage?, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        let alertController = UIAlertController(title: "Alert", message: "", preferredStyle: .Alert)
        if error == nil {
            alertController.message = "Image was sucessfuly saved in photo gallery."
        }
        else {
            alertController.message = "Image cannot be saved."
            print(error)
        }

        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func appendMorePhotos(sender: UIBarButtonItem) {
        displayPhotos()
    }
    
    @IBAction func clearGallery(sender: UIBarButtonItem) {
        results = [FlickrResults]()
        collectionView?.reloadData()
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

extension FlickrGalleryCollectionViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

        guard let text = textField.text else {
            return true
        }
        
        if text.isEmpty {
           return true
        }
        
        var filteredResults = [FlickrResults]()
        
        for photos in results {
            let filteredPhotos = photos.results.filter({ (photo:FlickrPhoto) -> Bool in
                for tag in photo.tags {
                    if tag == text {
                        return true
                    }
                }
                return false
            })
            
            if !filteredPhotos.isEmpty {
                filteredResults += [FlickrResults(results:filteredPhotos)]
            }
        }
        textField.text = ""
        self.results = filteredResults
        self.collectionView?.reloadData()

        return true
    }
}

