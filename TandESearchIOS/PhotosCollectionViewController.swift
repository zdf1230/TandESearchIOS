//
//  PhotosCollectionViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/21/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import GooglePlaces

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController {

    @IBOutlet var PhotosCollectionView: UICollectionView!
    var photosMetaData = [GMSPlacePhotoMetadata]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let placeDetails = (tabBarController as! DetailsViewController).placeDetails
        if let placeid = placeDetails["place_id"]?.stringValue {
            loadPhotosForPlace(placeID: placeid)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photosMetaData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotosCollectionViewCell
    
        loadImageForMetadata(photoMetadata: photosMetaData[indexPath.item], imageView: cell.photosImageView)
        
        return cell
    }
    
    func loadPhotosForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                self.view.showToast("Bad Internet Connection", position: .bottom, popTime: 2, dismissOnTap: true)
                print("Error: \(error.localizedDescription)")
            } else {
                if let metadata = photos?.results {
                    self.photosMetaData = metadata
                }
                if (self.photosMetaData.isEmpty) {
                    let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.self.PhotosCollectionView.bounds.size.width, height: self.PhotosCollectionView.bounds.size.height))
                    noDataLabel.text          = "No Photos"
                    noDataLabel.textAlignment = .center
                    self.PhotosCollectionView.backgroundView  = noDataLabel
                }
                self.PhotosCollectionView.reloadData()
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, imageView: UIImageView) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                self.view.showToast("Bad Internet Connection", position: .bottom, popTime: 2, dismissOnTap: true)
                print("Error: \(error.localizedDescription)")
            } else {
                imageView.image = photo;
            }
        })
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
