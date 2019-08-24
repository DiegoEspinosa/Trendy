//
//  AlbumCollectionViewController.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/22/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit

class AlbumCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "albumCell"
    private let trendingAlbumsUrl : URL = URL(string: "theaudiodb.com/api/v1/json/1/trending.php?country=us&type=itunes&format=albums")!
    private var albumArray : Array<Album>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        //make request to api
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumArray?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> AlbumCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCollectionViewCell
    
        // Configure the cell
        //cell.albumArtImageView.image =
        //cell.albumTitleLabel.text = 
    
        return cell
    }
    
    //MARK: - Retrieving Image
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadImage(from url: URL) {
        print("Download started")
        //var image : UIImage
        getData(from: url) { (data, response, error) in
            guard let data = data, error == nil else {return}
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download finished")
            DispatchQueue.main.async {
                //self.image = UIImage(data: data)
                //self.collectionView.reloadData()
            }
        }
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
