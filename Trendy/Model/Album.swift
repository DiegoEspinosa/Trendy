//
//  Album.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/24/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import Foundation
import UIKit

class Album {
    public var albumRank : Int = 0
    public var albumTitle : String = ""
    public var albumImageUrl : String = ""
    public var albumID : String = ""
    public var albumDescription : String = ""
    public var albumReleaseDate : String = ""
    public var albumLength : Int = 0
    
    public var albumArtist : String = ""
    public var albumArtistID : String = ""
    public var albumArtistImageUrl : String = ""
    
    init(rank: String, title: String, artist: String, albmId: String, artistId: String, imageUrl: String) {
        albumRank = Int(rank)!
        albumTitle = title
        albumArtist = artist
        albumImageUrl = imageUrl
        albumID = albmId
        albumArtistID = artistId
    }
}

//Trending Album Decodables
struct Root: Decodable {
    let trending : [AlbumData]
}

struct AlbumData: Decodable {
    var intChartPlace : String
    var strAlbum : String
    var strArtist : String
    var strAlbumThumb : String
    var idAlbum : String
    var idArtist : String
}

//Album Info Decodables
struct Main: Decodable {
    let album : [AlbumInfo]
}

struct AlbumInfo : Decodable {
    var strDescriptionEN : String
    var intYearReleased : String
}
