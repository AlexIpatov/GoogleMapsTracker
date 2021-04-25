//
//  LoginViewController.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 10.04.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class LoginViewController: UIViewController {
    private let realm = try! Realm()
    @IBOutlet var loginRouter: LoginRouter!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet  weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    var bag = DisposeBag()
    private(set) lazy var loginObservable = loginTextField.rx.text.orEmpty.asObservable()
    private(set) lazy var passwordObservable = passwordTextField.rx.text.orEmpty.asObservable()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginBinding()
        signUpButtonBinding()
        print(realm.configuration.fileURL!)
    }
    // MARK: - Methods
    private func setupInputSecurity() {
        loginTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
    }
    private func saveNewUser(login: String?, password: String?) {
        guard let login = login,
              let password = password else {
            return
        }
        try! realm.write{
            let newUser = User()
            newUser.login = login
            newUser.password = password
            realm.add(newUser)
        }
    }
    private func setupLoginBinding() {
        let loginButtonEnabled = Observable.combineLatest( loginObservable,
                                                           passwordObservable).map { [self](login: String,
                                                                                            password: String) -> Bool in
                                                            guard let user = realm.object(ofType: User.self, forPrimaryKey: login) else {
                                                                return false }
                                                            guard user.password == password else {
                                                                return false
                                                            }
                                                            return login.count >= 3 && password.count >= 6
                                                           }
        loginButtonEnabled
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: bag)
        loginButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] _ in
                self?.showAlert(title: "Hello!", message: nil) {
                    self?.loginRouter.toMain()
                    UserDefaults.standard.set(true, forKey: "isLogin")
                }
            }).disposed(by: bag)
    }
    private func signUpButtonBinding(){
        let signUpButtonEnabled = Observable.combineLatest( loginObservable,
                                                            passwordObservable).map { [self] (login: String,
                                                                                              password: String) -> Bool in
                                                                guard  realm.object(ofType: User.self, forPrimaryKey: login) == nil else  { return false }
                                                                return login.count >= 3 && password.count >= 6
                                                            }
        signUpButtonEnabled
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: bag)
        signUpButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] _ in
                self?.saveNewUser(login: self?.loginTextField.text, password: self?.passwordTextField.text!)
                self?.showAlert(title: "Hello!", message: nil) {
                    self?.loginRouter.toMain()
                    UserDefaults.standard.set(true, forKey: "isLogin")
                }
            }).disposed(by: bag)
    }
}
extension LoginViewController {
    func showAlert(title: String,
                   message: String?, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
