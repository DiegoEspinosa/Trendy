//
//  Networking.swift
//  Trendy
//
//  Created by Diego Espinosa on 9/5/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import Foundation
import PromiseKit

protocol MainNetworkingRequest {
    func fetchTrendingAlbums(from url: URL, albumDataCompletionHandler: @escaping ([AlbumData]?, Error?) -> Void)
}

protocol SecondaryNetworkingRequests {
    func fetchAlbumInfo(from url: URL, albumInfoCompletionHandler: @escaping ([AlbumInfo]?, Error?) -> Void)
    func fetchAlbumTracks(from url: URL, albumTracksCompletionHandler: @escaping ([Track]?, Error?) -> Void)
}

//rename protocol: AlbumAPI

//removing url from functions
