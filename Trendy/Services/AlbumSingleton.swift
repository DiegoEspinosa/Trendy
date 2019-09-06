//
//  Networking.swift
//  Trendy
//
//  Created by Diego Espinosa on 9/5/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import Foundation
import PromiseKit

protocol AlbumRepository {
    func fetchTrending(albumDataCompletionHandler: @escaping ([AlbumData]?, Error?) -> Void)
    func fetchInfo(albumId: String, albumInfoCompletionHandler: @escaping ([AlbumInfo]?, Error?) -> Void)
    func fetchTracks(albumId: String, albumTracksCompletionHandler: @escaping ([Track]?, Error?) -> Void)
}

class AlbumSingleton: AlbumRepository {
    
    static let shared = AlbumSingleton()
    
    private let trendingAlbumsUrl : URL = URL(string: "https://theaudiodb.com/api/v1/json/1/trending.php?country=us&type=itunes&format=albums&country=us&type=itunes&format=albums")!
    private var albumInfoString = "https://theaudiodb.com/api/v1/json/195003/album.php?m="
    private var albumTracksString = "https://theaudiodb.com/api/v1/json/195003/track.php?m="
    
    private init(){}
    
    func fetchTrending(albumDataCompletionHandler: @escaping ([AlbumData]?, Error?) -> Void) {
        Alamofire.request(trendingAlbumsUrl, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let jsonData = response.data
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Root.self, from: jsonData!)
                    let albums = root.trending
                    albumDataCompletionHandler(albums, nil)
                } catch {
                    print("Error decoding trending albums data")
                }
            } else {
                print("Error retrieving trending albums data")
            }
        }
    }
    
    func fetchInfo(albumId: String, albumInfoCompletionHandler: @escaping ([AlbumInfo]?, Error?) -> Void) {
        let url = URL(string: albumInfoString + albumId)!
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let jsonData = response.data
                do {
                    let jsonDecoder = JSONDecoder()
                    let mainAlbum = try jsonDecoder.decode(Main.self, from: jsonData!)
                    let albumInfo = mainAlbum.album
                    albumInfoCompletionHandler(albumInfo, nil)
                } catch {
                    print("Error decoding album info data")
                    albumInfoCompletionHandler(nil, response.error)
                }
            } else {
                print("Error retrieving album info data")
            }
        }
    }
    
    func fetchTracks(albumId: String, albumTracksCompletionHandler: @escaping ([Track]?, Error?) -> Void) {
        let url = URL(string: albumTracksString + albumId)!
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let jsonData = response.data
                do {
                    let jsonDecoder = JSONDecoder()
                    let tracks = try jsonDecoder.decode(Tracks.self, from: jsonData!)
                    let tracksArray = tracks.track
                    albumTracksCompletionHandler(tracksArray, nil)
                } catch {
                    print("Error decoding album tracks data")
                    albumTracksCompletionHandler(nil, response.error)
                }
            } else {
                print("Error retrieving album tracks data")
            }
        }
    }
    
    
}
