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
    var trackTime : MinSec = MinSec(min: 0, sec: 0)
    
    init(name: String, number: String, length: String) {
        trackName = name
        trackNum = Int(number)!
        
        let (min,sec) = secondsToMinutesSeconds(seconds: Int(length)! / 1000)
        trackTime.minutes = min
        trackTime.seconds = sec
    }
    
    private func secondsToMinutesSeconds(seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

struct MinSec {
    var minutes : Int
    var seconds : Int
    
    init(min: Int, sec: Int) {
        minutes = min
        seconds = sec
    }
}

struct Tracks: Decodable {
    var track : [Track]
}

struct Track: Decodable {
    var strTrack : String
    var intTrackNumber : String
    var intDuration : String
}
