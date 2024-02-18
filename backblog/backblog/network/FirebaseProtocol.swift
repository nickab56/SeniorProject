//
//  FirebaseProtocol.swift
//  backblog
//
//  Created by Jake Buhite on 2/15/24.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import Foundation

// Define a protocol for FirebaseService
protocol FirebaseProtocol {
    func get<T: Decodable>(type: T, query: Query?) async -> Result<T, Error>
    func exists(query: Query?) async -> Result<Bool, Error>
    func get<T: Decodable>(type: T, docId: String, collection: String) async -> Result<T, Error>
    func getBatch<T: Decodable>(type: T, query: Query?) async -> Result<[T], Error>
    func post<T: Codable>(data: T, collection: String) async -> Result<String, Error>
    func put<T: Codable>(doc: T, docId: String, collection: String) async -> Result<T, Error>
    func put(updates: [String: Any], docId: String, collection: String) async -> Result<Bool, Error>
    func delete<T: Codable>(doc: T, docId: String, collection: String) async -> Result<Bool, Error>
    func register(email: String, password: String) async -> Result<String, Error>
    func login(email: String, password: String) async -> Result<Bool, Error>
    func updatePassword(password: String, newPassword: String) async -> Result<Bool, Error>
    func logout() -> Result<Bool, Error>
    func getUserId() -> String?
    func getCollectionRef(refName: String) -> CollectionReference?
}
