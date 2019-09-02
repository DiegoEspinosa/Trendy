//
//  AlbumInfoTableViewController.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/29/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit
import Alamofire

class AlbumInfoTableViewController: UITableViewController {
    
    private var albumInfoString = "https://theaudiodb.com/api/v1/json/195003/album.php?m="
    private var albumTracksString = "https://theaudiodb.com/api/v1/json/195003/track.php?m="
    
    var album : Album?
    var albumTracks : Array<TrackObject> = []

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        if let currentAlbum = album {
            albumInfoString.append(currentAlbum.albumID)
            albumTracksString.append(currentAlbum.albumID)
            
            loadInAllData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumTracks.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = createHeaderSection()
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(400)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumInfoCell", for: indexPath) as! AlbumInfoTableViewCell

        cell.trackNumberLabel.text = String(albumTracks[indexPath.row].trackNum) + "."
        cell.trackTitleLabel.text = albumTracks[indexPath.row].trackName

        return cell
    }
    
    //MARK: - Private Functions
    private func loadInAllData() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let albumInfoUrl = URL(string: albumInfoString)
        fetchAlbumInfo(from: albumInfoUrl!) { (albumInfoArray, error) in
            self.album?.albumGenre = albumInfoArray?[0].strGenre ?? "Unable to find a genre for the album"
            self.album?.albumDescription = albumInfoArray?[0].strDescriptionEN ?? "Unable to find a description for the album"
            self.tableView.reloadData()
        }
        
        let albumTracksUrl = URL(string: albumTracksString)
        fetchAlbumTracks(from: albumTracksUrl!) { (trackArray, error) in
            if let tracks = trackArray {
                for track in tracks {
                    let track = TrackObject(name: track.strTrack, number: track.intTrackNumber)
                    self.albumTracks.append(track)
                    self.albumTracks.sort(by: { (trackOne, trackTwo) -> Bool in
                        trackOne.trackNum < trackTwo.trackNum
                    })
                    
                }
                self.tableView.reloadData()
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func fetchAlbumInfo(from url: URL, albumInfoCompletionHandler: @escaping ([AlbumInfo]?, Error?) -> Void) {
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let jsonData = response.data
                do {
                    let jsonDecoder = JSONDecoder()
                    let mainAlbum = try jsonDecoder.decode(Main.self, from: jsonData!)
                    let albumInfo = mainAlbum.album
                    albumInfoCompletionHandler(albumInfo, nil)
                } catch {
                    print("Error decoding data")
                    albumInfoCompletionHandler(nil, response.error)
                }
            } else {
                print("Error retrieving data")
            }
        }
    }
    
    private func fetchAlbumTracks(from url: URL, albumTracksCompletionHandler: @escaping ([Track]?, Error?) -> Void) {
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let jsonData = response.data
                do {
                    let jsonDecoder = JSONDecoder()
                    let tracks = try jsonDecoder.decode(Tracks.self, from: jsonData!)
                    let tracksArray = tracks.track
                    albumTracksCompletionHandler(tracksArray, nil)
                } catch {
                    print("Error decoding data")
                    albumTracksCompletionHandler(nil, response.error)
                }
            } else {
                print("Error retrieving data")
            }
        }
    }
    
    private func createHeaderSection() -> UIView {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(tableView.frame.width), height: 400))
        
        let imageView = UIImageView.init(frame: CGRect.init(x: (header.frame.width / 2) - 75, y: 8, width: 150 , height: 150))
        imageView.downloaded(from: (album?.albumImageUrl)!)
        
        let titleLabel = createAlbumTitleLabel(header: header)
        let artistLabel = createAlbumArtistLabel(header: header)
        let genreLabel = createAlbumGenreLabel(header: header)
        let descLabel = createAlbumDescLabel(header: header)
        
        header.addSubview(imageView)
        header.addSubview(titleLabel)
        header.addSubview(artistLabel)
        header.addSubview(genreLabel)
        header.addSubview(descLabel)
        
        header.clipsToBounds = true
        return header
    }
    
    private func createAlbumTitleLabel(header: UIView) -> UILabel {
        let title = UILabel()
        title.frame = CGRect.init(x: 0, y: 158, width: header.frame.width, height: 25)
        title.text = album?.albumTitle
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = UIColor.black
        title.textAlignment = .center
        return title
    }
    
    private func createAlbumArtistLabel(header: UIView) -> UILabel {
        let artist = UILabel()
        artist.frame = CGRect.init(x: 0, y: 183, width: header.frame.width, height: 25)
        artist.text = album?.albumArtist
        artist.font = UIFont.systemFont(ofSize: 16)
        artist.textColor = UIColor.black
        artist.textAlignment = .center
        return artist
    }
    
    private func createAlbumGenreLabel(header: UIView) -> UILabel {
        let genre = UILabel()
        genre.frame = CGRect.init(x: 0, y: 208, width: header.frame.width, height: 25)
        genre.text = album?.albumGenre
        genre.font = UIFont.systemFont(ofSize: 14)
        genre.textColor = UIColor.black
        genre.textAlignment = .center
        return genre
    }
    
    private func createAlbumDescLabel(header: UIView) -> UILabel {
        let description = UILabel()
        description.frame = CGRect.init(x: 5, y: 233, width: header.frame.width - 25, height: 150)
        description.text = album?.albumDescription
        description.font = UIFont.systemFont(ofSize: 14)
        description.textColor = UIColor.black
        description.textAlignment = .center
        description.lineBreakMode = .byWordWrapping
        description.numberOfLines = 100
        return description
    }

}
