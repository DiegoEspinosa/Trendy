//
//  Album.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/24/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import Foundation

class Album {
    public var albumTitle : String = ""
    public var albumImageUrl : String = ""
    
    init(title: String, imageUrl: String) {
        albumTitle = title
        albumImageUrl = imageUrl
    }
    
}
