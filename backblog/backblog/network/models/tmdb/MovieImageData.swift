//
//  MovieImageData.swift
//  backblog
//
//  Created by Jake Buhite on 1/28/24.
//

import Foundation

struct MovieImageData: Codable {
    var backdrops: [Image]?
    var logos: [Image]?
    var posters: [Image]?
    var id: Int?
    
    struct Image: Codable {
        var aspectRatio: Double?
        var height: Int?
        var iso6391: String?
        var filePath: String?
        var voteAverage: Double?
        var voteCount: Int?
        var width: Int?
        
        enum CodingKeys: String, CodingKey {
            case height, width
            case aspectRatio = "aspect_ratio"
            case iso6391 = "iso_639_1"
            case filePath = "file_path"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }
}
