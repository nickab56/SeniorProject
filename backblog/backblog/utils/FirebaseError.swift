//
//  FirebaseError.swift
//  backblog
//
//  Created by Jake Buhite on 1/26/24.
//

import Foundation
import FirebaseAuth

enum FirebaseError: Error {
    case notFound
    case nullProperty
    case failedTransaction
    case authError(String)
}

func getErrorMessage(errorCode: Error) -> String {
    switch (errorCode) {
    case AuthErrorCode.invalidEmail: return "Invalid email."
    case AuthErrorCode.wrongPassword: return"Invalid password."
    case AuthErrorCode.invalidCredential: return "Incorrect email or password."
    case AuthErrorCode.credentialAlreadyInUse: return "An account already exists with the same email address."
    case AuthErrorCode.emailAlreadyInUse: return "Email already in use."
    case AuthErrorCode.userDisabled: return "The user account has been disabled by an administrator."
    case AuthErrorCode.userNotFound: return "User not found."
    default: return "There was an error authenticating."
    }
}
