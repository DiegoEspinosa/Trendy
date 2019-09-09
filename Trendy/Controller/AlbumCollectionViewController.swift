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
    private let trendingAlbumsUrl : URL = URL(string: "https://theaudiodb.com/api/v1/json/1/trending.php?country=us&type=itunes&format=albums&country=us&type=itunes&format=albums")!
    private var albumArray : Array<Album> = []
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        loadAllAlbums(from: trendingAlbumsUrl)
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
    private func loadAllAlbums(from url: URL) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        firstly {
            AlbumSingleton.shared.fetchTrending()
            }.map { albumDataArray in
                self.createAlbumObjects(albumJsonArray: albumDataArray)
            }.done {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }.catch { (error) in
                print("Error: \(error)")
        }
    }
    
    private func createAlbumObjects(albumJsonArray: [AlbumData]) {
        for album in albumJsonArray.reversed() {
            let albumObject = Album(rank: album.intChartPlace, title: album.strAlbum, artist: album.strArtist, id: album.idAlbum, imageUrl: album.strAlbumThumb)
            albumArray.append(albumObject)
        }
        collectionView.reloadData()
    }
}

