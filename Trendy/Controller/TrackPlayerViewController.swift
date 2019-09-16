//
//  TrackPlayerViewController.swift
//  Trendy
//
//  Created by Diego Espinosa on 9/15/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit

class TrackPlayerViewController: UIViewController {

    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    var album : Album?
    var track : TrackObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if album != nil && track != nil {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            guard let albumTitle = album?.albumTitle else {fatalError("Error setting title")}
            navItem.title = albumTitle
            
            loadAlbumImage()
            fillInData()
            
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            
        }
    }
    
    private func loadAlbumImage() {
        guard let imageUrl = album?.albumImageUrl else {fatalError("Error setting album image url")}
        trackImageView.downloadImage(from: imageUrl)
    }
    
    private func fillInData() {
        guard let track = track else {fatalError("Error setting track object")}
        guard let album = album else {fatalError("Error setting album object")}
        
        trackNameLabel.text = track.trackName
        trackArtistLabel.text = album.albumArtist
        if track.trackTime.seconds < 10 {
            endTimeLabel.text = String(track.trackTime.minutes) + ":0" + String(track.trackTime.seconds)
        } else {
            endTimeLabel.text = String(track.trackTime.minutes) + ":" + String(track.trackTime.seconds)
        }
        startTimeLabel.text = "0:00"
        
    }
}
