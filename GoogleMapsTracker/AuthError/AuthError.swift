//
//  AuthError.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 11.04.2021.
//

import Foundation

enum AuthError {
    case notFilled, unknownError, alreadyHaveAccount, noSuchUser, invalidPassword
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Empty fields", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown error", comment: "")
        case .alreadyHaveAccount:
            return NSLocalizedString("You already have an account", comment: "")
        case .noSuchUser:
            return NSLocalizedString("There is no user with this login", comment: "")
        case .invalidPassword:
            return NSLocalizedString("Invalid password", comment: "")
        }
    }
}
