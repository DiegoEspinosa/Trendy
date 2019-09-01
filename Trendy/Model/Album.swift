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
    public var albumArtist : String = ""
    public var albumImageUrl : String = ""
    public var albumID : String = ""
    
    
    init(rank: String, title: String, artist: String, id: String, imageUrl: String) {
        albumRank = Int(rank)!
        albumTitle = title
        albumArtist = artist
        albumImageUrl = imageUrl
        albumID = id
    }
}

struct Root: Decodable {
    let trending : [AlbumData]
}

struct AlbumData: Decodable {
    var intChartPlace : String
    var strAlbum : String
    var strArtist : String
    var strAlbumThumb : String
    var idAlbum : String
}
