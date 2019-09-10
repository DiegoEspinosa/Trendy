//
//  AlbumCollectionViewController.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/22/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class AlbumCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "albumCell"
    private var albumArray : Array<Album> = []
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        loadTrendingAlbums()
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> AlbumCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCollectionViewCell
        // Configure the cell
        let album = albumArray[indexPath.row]
        cell.albumArtImageView.downloadImage(from: album.albumImageUrl, contentMode: .scaleAspectFill)
        cell.albumTitleLabel.text = album.albumTitle
        cell.albumArtistLabel.text = album.albumArtist
        cell.albumRankLabel.text = String(album.albumRank)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AlbumInfoTableViewController {
            guard let albumInfoTableVC = segue.destination as? AlbumInfoTableViewController else {fatalError("Error setting table view controller")}
            guard let selectedCell = sender as? AlbumCollectionViewCell else {fatalError("Error setting cell")}
            guard let indexPath = collectionView.indexPath(for: selectedCell) else {fatalError("Error getting indexPath")}
            
            let selectedAlbum = albumArray[indexPath.row]
            albumInfoTableVC.album = selectedAlbum
        }
    }

    //MARK: - Private functions
    private func loadTrendingAlbums() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        AlbumSingleton.shared.fetchTrending().map { trendingAlbumArray in
                self.createAlbumObjects(from: trendingAlbumArray)
            }.done {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }.catch { (error) in
                let alert = UIAlertController(title: "Something went wrong", message: "There was a problem retrieving data. Please try again", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
        }
    }
    
    private func createAlbumObjects(from trendingAlbumArray: [AlbumData]) {
        for album in trendingAlbumArray.reversed() {
            let albumObject = Album(rank: album.intChartPlace, title: album.strAlbum, artist: album.strArtist, id: album.idAlbum, imageUrl: album.strAlbumThumb)
            albumArray.append(albumObject)
        }
        collectionView.reloadData()
    }
}

