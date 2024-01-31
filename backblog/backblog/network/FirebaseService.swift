//
//  FirebaseService.swift
//  backblog
//
//  Created by Jake Buhite on 1/26/24.
//

import Firebase
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseAuth
import Foundation
import SwiftUI

class FirebaseService {
    let fbConfig: Void = FirebaseApp.configure()
    static let shared = FirebaseService()
    let db = Firestore.firestore()
    let auth = FirebaseAuth.Auth.auth()
    
    // From query
    func get<T: Decodable>(type: T, query: Query) async -> Result<T, Error> {
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
    
    // From doc ref
    func get<T: Decodable>(type: T, docId: String, collection: String) async -> Result<T, Error> {
        do {
            let docRef =  db.collection(collection).document(docId)
            let doc = try await docRef.getDocument()
            
            if (doc.exists) {
                let decodedDoc = try doc.data(as: T.self)
                return.success(decodedDoc)
            }
            
            print("Error: Document not found")
            return .failure(FirebaseError.notFound)
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    func getBatch<T: Decodable>(type: T, query: Query) async -> Result<[T], Error> {
        do {
            let snap = try await query.getDocuments()
            
            let result = try snap.documents.map { doc in
                do {
                    return try doc.data(as: T.self)
                } catch {
                    throw error
                }
            }
            
            return .success(result)
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    func post<T: Codable>(data: T, collection: String) async -> Result<T, Error> {
        let docRef = db.collection(collection).document()
        let newData: T = data
        
        do {
            try docRef.setData(from: newData)
            return .success(newData)
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    // Update entire document
    func put<T: Codable>(doc: T, docId: String, collection: String) async -> Result<T, Error> {
        let docRef = db.collection(collection).document(docId)
        
        do {
            try docRef.setData(from: doc)
            return .success(doc) // Updated document
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    // Update specific properties
    func put(updates: [String: Any], docId: String, collection: String) async -> Result<Bool, Error> {
        let docRef = db.collection(collection).document(docId)
        
        do {
            try await docRef.updateData(updates)
            return .success(true) // Updated document
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    func delete<T: Codable>(doc: T, docId: String, collection: String) async -> Result<Bool, Error> {
        let docRef = db.collection(collection).document(docId)
        
        do {
            try await docRef.delete()
            return .success(true)
        } catch {
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    func register(email: String, password: String) async -> Result<String, Error> {
        do {
            _ = try await auth.createUser(withEmail: email, password: password)
            
            guard let userId = auth.currentUser?.uid else {
                return .failure(FirebaseError.failedTransaction)
            }
            
            return .success(userId)
        } catch {
            print("Error registering user: \(error)")
            return .failure(error)
        }
    }
    
    func login(email: String, password: String) async -> Result<Bool, Error> {
        do {
            _ = try await auth.signIn(withEmail: email, password: password)
            
            return .success(true)
        } catch {
            print("Error logging in: \(error)")
            return .failure(error)
        }
    }
}
