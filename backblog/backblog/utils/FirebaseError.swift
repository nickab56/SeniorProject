//
//  FirebaseError.swift
//  backblog
//
//  Created by Jake Buhite on 1/26/24.
//

import Foundation

enum FirebaseError: Error {
    case notFound
    case nullProperty
    case failedTransaction
}
