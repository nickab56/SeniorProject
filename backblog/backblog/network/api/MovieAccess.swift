//
//  MovieAccess.swift
//  backblog
//
//  Created by Jake Buhite on 1/26/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: Manages the secrets for the movie API.
//

import Foundation

/// A class responsible for providing access to movie-related data and services.
class MovieAccess {
    /// The shared instance of MovieAccess
    static let shared = MovieAccess()

    /// The secret token used for authenticating requests to the movie API.
    let MOVIE_SECRET = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5OTI1YjVjYWM4NDI5MGYzZWRmZTg4OTJlYjdhMTA1NiIsInN1YiI6IjY1ODcwMjY1ZWE3YjBlNWU0YzhmYTg0ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.u3581mLT0Qf_g2mpF1rVU3JSz2fMV2qqkripARfhqyg"
}
