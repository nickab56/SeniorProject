//
//  MockFirebaseService.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/12/24.
//

import Firebase
import FirebaseFirestoreSwift
@testable import backblog

class MockFirebaseService: FirebaseService {
    override func get<T: Decodable>(type: T, query: Query) async -> Result<T, Error> {
        do {
            let snap = try await query.getDocuments()
            
            guard let doc = snap.documents.first else {
                // Doc not found
                print("Error: Document not found")
                return .failure(FirebaseError.notFound)
            }
            
            let result = try doc.data(as: T.self)
            return .success(result)
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    override func exists(query: Query) async -> Result<Bool, Error> {
        do {
            let snap = try await query.getDocuments()
            
            guard snap.documents.first != nil else {
                // Doc not found
                return .success(false)
            }
            
            return .success(true)
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    // From doc ref
    override func get<T: Decodable>(type: T, docId: String, collection: String) async -> Result<T, Error> {
        do {
            let docRef =  db.collection(collection).document(docId)
            let doc = try await docRef.getDocument()
            
            if (doc.exists) {
                let decodedDoc = try doc.data(as: T.self)
                return.success(decodedDoc)
            }
            
            print("Error: Document not found")
            print("The document Id of this error: \(docId)")
            return .failure(FirebaseError.notFound)
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    override func getBatch<T: Decodable>(type: T, query: Query) async -> Result<[T], Error> {
        let result: [T] = []
        return .success(result)
    }
    
    override func post<U: Codable>(data: U, collection: String) async -> Result<String, Error> {
        return .success("newDoc123")
    }
    
    override func put<U: Codable>(doc: U, docId: String, collection: String) async -> Result<U, Error> {
        return .success(doc)
    }
    
    override func put(updates: [String: Any], docId: String, collection: String) async -> Result<Bool, Error> {
        return .success(true)
    }
    
    override func delete<U: Codable>(doc: U, docId: String, collection: String) async -> Result<Bool, Error> {
        return .success(true)
    }
    
    override func register(email: String, password: String) async -> Result<String, Error> {
        return .success("user123")
    }
    
    override func login(email: String, password: String) async -> Result<Bool, Error> {
        return .success(true)
    }
    
    override func updatePassword(password: String, newPassword: String) async -> Result<Bool, Error> {
        return .success(true)
    }
    
    override func logout() -> Result<Bool, Error> {
        return .success(true)
    }
}
