//
//  AlbumCollectionViewController.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/22/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit
import Alamofire

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
    
    private func loadAllAlbums(from url: URL) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        //let albumDataArray = fetchTrendingAlbums(from: url, albumDataCompletionHandler: (AlbumData?, Error?))
        fetchTrendingAlbums(from: url) { (album, error) in
            guard let albumDataArray = album else {fatalError("error setting album") }
            self.createAlbumObjects(albumJsonArray: albumDataArray)
        }
        
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
    //MARK: - Private functions
    private func fetchTrendingAlbums(from url: URL, albumDataCompletionHandler: @escaping ([AlbumData]?, Error?) -> Void){
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let jsonData = response.data
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Root.self, from: jsonData!)
                    let albums = root.trending
                    albumDataCompletionHandler(albums, nil)
                } catch {
                    print("Error: \(error)")
                }
            } else {
                let alert = UIAlertController(title: "Something went wrong", message: "There was a problem retrieving data. Please try again", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                albumDataCompletionHandler(nil, response.error)
            }
        }
    }
    
    private func createAlbumObjects(albumJsonArray: [AlbumData]) {
        for album in albumJsonArray.reversed() {
            let albumObject = Album(rank: album.intChartPlace, title: album.strAlbum, artist: album.strArtist, imageUrl: album.strAlbumThumb)
            albumArray.append(albumObject)
        }
        collectionView.reloadData()
        activityIndicatorView.stopAnimating()
    }
}
