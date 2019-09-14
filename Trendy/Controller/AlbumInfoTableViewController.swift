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
        
        tableView.separatorStyle = .singleLine
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        if album != nil {
            loadInAllData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return albumTracks.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header : UIView = UIView()
        if section == 0 {
        header = createHeaderSection()
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = CGFloat(0)
        if section == 0 {
            height = CGFloat(200)
        }
        return height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //First static cell in first section (Artist Image and Name)
            let cell = tableView.dequeueReusableCell(withIdentifier: "artistInfoCell", for: indexPath) as! AlbumArtistTableViewCell
            guard let artistName = album?.albumArtist else {fatalError("Error setting name")}
            guard let artistImageString = album?.albumArtistImageUrl else {fatalError("Error setting artist image url")}
            cell.artistLabel.text = artistName
            cell.artistImageView.downloadImage(from: artistImageString)
            return cell
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            //First static cell in second section (Total songs and total length in minutes)
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalTracksInfoCell", for: indexPath) as! AlbumTotalTracksInfoTableViewCell
            guard let albumLength = album?.albumLength else {fatalError("Error setting album length")}
            cell.totalTracksInfoCell.text = "\(albumTracks.count) songs * \(albumLength) minutes"
            cell.totalTracksInfoCell.textAlignment = .left
            return cell
        } else {
            //Dyanmic cells (track number, track title, and track length)
            let cell = tableView.dequeueReusableCell(withIdentifier: "albumInfoCell", for: indexPath) as! AlbumTrackInfoTableViewCell
            if indexPath.row > 0 && indexPath.row <= albumTracks.count {
                cell.trackNumberLabel.text = String(albumTracks[indexPath.row-1].trackNum) + "."
                cell.trackTitleLabel.text = albumTracks[indexPath.row-1].trackName
                cell.trackLengthLabel.text = String(albumTracks[indexPath.row-1].trackLength) + " minutes"
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height : CGFloat = 50
        return height
    }
    
    //MARK: - Private Functions
    private func loadInAllData() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard let id = album?.albumID else {fatalError("Error setting album ID")}
        
        let promiseInfo = AlbumSingleton.shared.fetchInfo(albumId: id)
        let promiseTracks = AlbumSingleton.shared.fetchTracks(albumId: id)
        guard let artistId = album?.albumArtistID else {fatalError("Error setting artist ID")}
        let promiseArtist = AlbumSingleton.shared.fetchArtist(artistId: artistId)
        
        when(fulfilled: promiseInfo, promiseTracks, promiseArtist).map { albumInfo, trackArray, artist in
                self.album?.albumDescription = albumInfo.strDescriptionEN
                self.album?.albumReleaseDate = albumInfo.intYearReleased
            
                self.album?.albumArtistImageUrl = artist.strArtistThumb
            
                self.createTrackObjects(from: trackArray)
            }.done {
                self.tableView.reloadData()
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
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
        var totalTime = 0
        for track in tracks {
            let track = TrackObject(name: track.strTrack, number: track.intTrackNumber, length: track.intDuration)
            self.albumTracks.append(track)
            self.albumTracks.sort(by: { (trackOne, trackTwo) -> Bool in
                trackOne.trackNum < trackTwo.trackNum
            })
            totalTime += track.trackLength
        }
        album?.albumLength = String(totalTime)
    }
    
    @objc private func infoButtonTapped() {
        self.performSegue(withIdentifier: "toAlbumDescription", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAlbumDescription" {
            guard let albumDescriptionVC = segue.destination as? AlbumDescriptionViewController else {fatalError("Error setting view controller")}
            guard let albumDescription = album?.albumDescription else {fatalError("Error setting album description")}
            
            albumDescriptionVC.albumDescription = albumDescription
        }
    }
    
    private func createHeaderSection() -> UIView {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(tableView.frame.width), height: 300))
        
        let imageView = UIImageView.init(frame: CGRect.init(x: 16, y: 16, width: 150 , height: 150))
        if let imageUrl = album?.albumImageUrl {
            imageView.downloadImage(from: imageUrl)
        }
        
        let titleLabel = createAlbumTitleLabel(header: header)
        let releaseDateLabel = createAlbumReleaseDateLabel(header: header)
        let saveButton = createSaveButton()
        let shareButton = createShareButton()
        
        header.addSubview(imageView)
        header.addSubview(titleLabel)
        header.addSubview(releaseDateLabel)
        header.addSubview(saveButton)
        header.addSubview(shareButton)
        
        header.clipsToBounds = true
        return header
    }
    
    private func createAlbumTitleLabel(header: UIView) -> UILabel {
        let title = UILabel()
        title.frame = CGRect.init(x: 190, y: 16, width: header.frame.width / 2, height: 50)
        if let albumTitle = album?.albumTitle {
            title.text = albumTitle
        }
        title.font = UIFont.systemFont(ofSize: 18)
        title.numberOfLines = 0
        title.textColor = UIColor.black
        title.textAlignment = .left
        return title
    }
    
    private func createAlbumReleaseDateLabel(header: UIView) -> UILabel {
        let releaseDate = UILabel()
        releaseDate.frame = CGRect.init(x: 190, y: 66, width: header.frame.width / 2, height: 25)
        if let albumReleaseDate = album?.albumReleaseDate {
            releaseDate.text = "Released in " + albumReleaseDate
        }
        releaseDate.font = UIFont.systemFont(ofSize: 16)
        releaseDate.textColor = UIColor.black
        releaseDate.textAlignment = .left
        return releaseDate
    }
    
    private func createSaveButton() -> UIButton {
        let saveButton = UIButton(frame: CGRect(x: 184, y: 100, width: 30, height: 30))
        saveButton.backgroundColor = UIColor.clear
        saveButton.setTitleColor(UIColor.black, for: .normal)
        saveButton.setImage(UIImage(named: "Save"), for: .normal)
        return saveButton
    }
    
    private func createShareButton() -> UIButton {
        let shareButton = UIButton(frame: CGRect(x: 222, y: 100, width: 30, height: 30))
        shareButton.backgroundColor = UIColor.clear
        shareButton.setTitleColor(UIColor.black, for: .normal)
        shareButton.setImage(UIImage(named: "Share"), for: .normal)
        return shareButton
    }

}
