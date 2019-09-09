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
    func fetchTrending() -> Promise<[AlbumData]>
    func fetchInfo(albumId: String) -> Promise<AlbumInfo>
    func fetchTracks(albumId: String, albumTracksCompletionHandler: @escaping ([Track]?, Error?) -> Void)
}

class AlbumSingleton: AlbumRepository {
    
    static let shared = AlbumSingleton()
    
    private let trendingAlbumsUrl : URL = URL(string: "https://theaudiodb.com/api/v1/json/1/trending.php?country=us&type=itunes&format=albums&country=us&type=itunes&format=albums")!
    private var albumInfoString = "https://theaudiodb.com/api/v1/json/195003/album.php?m="
    private var albumTracksString = "https://theaudiodb.com/api/v1/json/195003/track.php?m="
    
    private init(){}
    
    func fetchTrending() -> Promise<[AlbumData]> {
        return Promise { seal in
            Alamofire.request(trendingAlbumsUrl, method: .get).responseJSON {response in
                if let jsonData = response.data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let root = try jsonDecoder.decode(Root.self, from: jsonData)
                        let albums = root.trending
                        seal.fulfill(albums)
                    } catch {
                        seal.reject(error)
                    }
                }
                if let error = response.error {
                    seal.reject(error)
                }
            }
        }
    }
    
    func fetchInfo(albumId: String) -> Promise<AlbumInfo> {
        let url = URL(string: albumInfoString + albumId)!
        return Promise { seal in
            Alamofire.request(url, method: .get).responseJSON {response in
                if let jsonData = response.data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let mainAlbum = try jsonDecoder.decode(Main.self, from: jsonData)
                        let albumInfo = mainAlbum.album[0]
                        seal.fulfill(albumInfo)
                    } catch {
                        seal.reject(error)
                    }
                }
                if let error = response.error {
                    seal.reject(error)
                }
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
