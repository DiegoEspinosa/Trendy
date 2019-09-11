//
//  AlbumInfoTableViewController.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/29/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class AlbumInfoTableViewController: UITableViewController {
    
    var album : Album?
    var albumTracks : Array<TrackObject> = []

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        if album != nil {
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
        
        guard let id = album?.albumID else {fatalError("Error setting album ID")}
        
        let promiseInfo = AlbumSingleton.shared.fetchInfo(albumId: id)
        let promiseTracks = AlbumSingleton.shared.fetchTracks(albumId: id)
        
        when(fulfilled: promiseInfo, promiseTracks).map { albumInfo, trackArray in
                self.album?.albumGenre = albumInfo.strGenre
                self.album?.albumDescription = albumInfo.strDescriptionEN
                self.createTrackObjects(from: trackArray)
            }.done {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }.catch { (error) in
                self.displayAlertForError()
        }
    }
    
    private func displayAlertForError() {
        let alert = UIAlertController(title: "Something went wrong", message: "There was a problem retrieving data. Please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func createTrackObjects(from tracks: [Track]) {
        for track in tracks {
            let track = TrackObject(name: track.strTrack, number: track.intTrackNumber)
            self.albumTracks.append(track)
            self.albumTracks.sort(by: { (trackOne, trackTwo) -> Bool in
                trackOne.trackNum < trackTwo.trackNum
            })
        }
    }
    
    @objc private func infoButtonTapped() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumDescriptionViewController") as! AlbumDescriptionViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    
    private func createHeaderSection() -> UIView {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(tableView.frame.width), height: 400))
        
        let imageView = UIImageView.init(frame: CGRect.init(x: (header.frame.width / 2) - 75, y: 8, width: 150 , height: 150))
        if let imageUrl = album?.albumImageUrl {
            imageView.downloadImage(from: imageUrl)
        }
        
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
        if let albumTitle = album?.albumTitle {
            title.text = albumTitle
        }
        title.font = UIFont.systemFont(ofSize: 18)
        title.textColor = UIColor.black
        title.textAlignment = .center
        return title
    }
    
    private func createAlbumArtistLabel(header: UIView) -> UILabel {
        let artist = UILabel()
        artist.frame = CGRect.init(x: 0, y: 183, width: header.frame.width, height: 25)
        if let artistName = album?.albumArtist {
            artist.text = artistName
        }
        artist.font = UIFont.systemFont(ofSize: 18)
        artist.textColor = UIColor.black
        artist.textAlignment = .center
        return artist
    }
    
    private func createAlbumGenreLabel(header: UIView) -> UILabel {
        let genre = UILabel()
        genre.frame = CGRect.init(x: 0, y: 208, width: header.frame.width, height: 25)
        if let albumGenre = album?.albumGenre {
            genre.text = albumGenre
        }
        genre.font = UIFont.systemFont(ofSize: 16)
        genre.textColor = UIColor.black
        genre.textAlignment = .center
        return genre
    }
    
    private func createAlbumDescLabel(header: UIView) -> UILabel {
        let description = UILabel()
        description.frame = CGRect.init(x: 5, y: 233, width: header.frame.width - 25, height: 150)
        if let albumDescription = album?.albumDescription {
            description.text = albumDescription
        }
        description.font = UIFont.systemFont(ofSize: 15)
        description.textColor = UIColor.black
        description.textAlignment = .center
        description.lineBreakMode = .byTruncatingTail
        description.numberOfLines = 0
        return description
    }

}
