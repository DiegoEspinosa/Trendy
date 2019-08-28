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

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        fetchTrendingAlbums(from: trendingAlbumsUrl)
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
        cell.albumArtImageView.downloaded(from: album.albumImageUrl, contentMode: .scaleAspectFill)
        cell.albumTitleLabel.text = album.albumTitle
        cell.albumArtistLabel.text = album.albumArtist
        cell.albumRankLabel.text = String(album.albumRank)
        return cell
    }
    
    //MARK: - Private functions    
    private func fetchTrendingAlbums(from url: URL) {
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                if let jsonResult = response.result.value as? [String: Any] {
                    if let albumJson = jsonResult["trending"] as? NSArray {
                        self.createAlbumObjects(albumJsonArray: albumJson)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Something went wrong", message: "There was a problem retrieving data. Please try again", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func createAlbumObjects(albumJsonArray: NSArray) {
        for album in albumJsonArray {
            let albumInfo = album as? NSDictionary
            let albumObject = Album(rank: albumInfo?["intChartPlace"] as! String, title: albumInfo?["strAlbum"] as! String, artist: albumInfo?["strArtist"] as! String ,imageUrl: albumInfo?["strAlbumThumb"] as! String)
            albumArray.append(albumObject)
        }
        sortAlbumInOrder()
        collectionView.reloadData()
    }
    
    private func sortAlbumInOrder() {
        albumArray = albumArray.sorted(by: {$0.albumRank < $1.albumRank})
    }
}

//MARK: - UIImageView Extension
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
