//
//  Artist.swift
//  Trendy
//
//  Created by Diego Espinosa on 9/13/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import Foundation

struct ArtistArray : Decodable {
    var artists : [Artist]
}

struct Artist : Decodable {
    var strArtistThumb : String
}
