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
    func fetchTracks(albumId: String) -> Promise<[Track]>
    func fetchArtist(artistId: String) -> Promise<Artist>
}

class AlbumSingleton: AlbumRepository {
    
    static let shared = AlbumSingleton()
    
    private let trendingAlbumsUrl : URL = URL(string: "https://theaudiodb.com/api/v1/json/1/trending.php?country=us&type=itunes&format=albums&country=us&type=itunes&format=albums")!
    private var albumInfoString = "https://theaudiodb.com/api/v1/json/195003/album.php?m="
    private var albumTracksString = "https://theaudiodb.com/api/v1/json/195003/track.php?m="
    private var albumArtistString = "https://theaudiodb.com/api/v1/json/195003/artist.php?i="
    
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
    
    func fetchTracks(albumId: String) -> Promise<[Track]> {
        let url = URL(string: albumTracksString + albumId)!
        return Promise { seal in
            Alamofire.request(url, method: .get).responseJSON { (response) in
                if let jsonData = response.data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let tracks = try jsonDecoder.decode(Tracks.self, from: jsonData)
                        let tracksArray = tracks.track
                        seal.fulfill(tracksArray)
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
    
    func fetchArtist(artistId: String) -> Promise<Artist> {
        let url = URL(string: albumArtistString + artistId)!
        return Promise { seal in
            Alamofire.request(url, method: .get).responseJSON { (response) in
                if let jsonData = response.data {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let artistArray = try jsonDecoder.decode(ArtistArray.self, from: jsonData)
                        let artist = artistArray.artists[0]
                        seal.fulfill(artist)
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
    
    
}
