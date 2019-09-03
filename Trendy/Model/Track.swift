//
//  Track.swift
//  Trendy
//
//  Created by Diego Espinosa on 9/2/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import Foundation

class TrackObject {
    var trackName : String = ""
    var trackNum : Int = 0
    
    init(name: String, number: String) {
        trackName = name
        trackNum = Int(number)!
    }
}

struct Tracks: Decodable {
    var track : [Track]
}

struct Track: Decodable {
    var strTrack : String
    var intTrackNumber : String
}
