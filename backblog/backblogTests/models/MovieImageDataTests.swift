//
//  MovieImageDataTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class MovieImageDataTests: XCTestCase {

    func testCodable() {
        let data = MovieImageData(backdrops: [MovieImageData.Image](), logos: [MovieImageData.Image](), posters: [MovieImageData.Image](), id: 123)
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            let decodedData = try JSONDecoder().decode(MovieImageData.self, from: jsonData)
            XCTAssertEqual(data, decodedData)
        } catch {
            XCTFail("Failed to encode or decode MovieImageData: \(error)")
        }
    }
}

