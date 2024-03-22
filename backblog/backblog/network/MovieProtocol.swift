//
//  MovieProtocol.swift
//  backblog
//
//  Created by Jake Buhite on 3/21/24.
//

protocol MovieProtocol {
    func searchMovie(query: String, includeAdult: Bool, language: String, page: Int) async -> Result<MovieSearchData, Error>
   
    func getMovieByID(movieId: String) async -> Result<MovieData, Error>
    
    func getMovieHalfSheet(movieId: String) async -> Result<String, Error>
    
    func getMoviePoster(movieId: String) async -> Result<String, Error>
}
