//
//  AuthService.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 11.04.2021.
//

import Foundation
import RealmSwift

class AuthService {
    private let realm = try! Realm()
    static let shared = AuthService()

    func login(login: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void) {
        guard let login = login, let password = password else {
            completion(.failure(AuthError.unknownError))
            return
        }
        guard Validators.isFilled(login: login, password: password)
        else {  completion(.failure(AuthError.notFilled))
            return
        }
        guard let user = realm.object(ofType: User.self, forPrimaryKey: login) else {
            completion(.failure(AuthError.noSuchUser))
            return}
        guard user.password == password else {
            completion(.failure(AuthError.invalidPassword))
            return
        }
        completion(.success(user))
        UserDefaults.standard.set(true, forKey: "isLogin")
        print(realm.configuration.fileURL!)
    }

    func signUp(login: String?, password: String?,completion: @escaping (Result<User, Error>) -> Void) {
        guard let login = login, let password = password else {
            completion(.failure(AuthError.unknownError))
            return
        }
        guard Validators.isFilled(login: login, password: password)
        else {  completion(.failure(AuthError.notFilled))
            return
        }
        guard  realm.object(ofType: User.self, forPrimaryKey: login) == nil else  {completion(.failure(AuthError.alreadyHaveAccount))
            return
        }
        try! realm.write{
            let newUser = User()
            newUser.login = login
            newUser.password = password
            realm.add(newUser)
            completion(.success(newUser))
        }
        print(realm.configuration.fileURL!)
    }
}
